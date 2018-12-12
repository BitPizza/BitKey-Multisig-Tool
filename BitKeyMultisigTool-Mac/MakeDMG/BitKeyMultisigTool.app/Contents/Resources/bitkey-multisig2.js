const debug = false;
function print(n) { debug && console.log(n) };
const bitcoin = foo;

function decimalToHexString(d) {
    var s = (d).toString(16);
    if (s.length % 2) {
        s = '0' + s;
    }
    return s;
}

function buffer2hex(buffer) { // buffer is an ArrayBuffer
    return Array.prototype.map.call(new Uint8Array(buffer), x => ('00' + x.toString(16)).slice(-2)).join('');
}

function buffer2Base64(buffer) { //
    return buffer.toString('base64');
}

function hex2Buffer(hex) { // hex string ->  buffer is an ArrayBuffer
    return bitcoin.SafeBuffer.from(hex, 'hex');
}

function reverseString(str) {
    return str.split("").reverse().join("");
}

function JsonOrBase64parse(string) {
    var obj = null;
    try{
        obj = JSON.parse(string);
    }
    catch(e){
    }
    
    if(!obj){
        try{
            obj = JSON.parse(atob(string));
        }
        catch(e){
        }
    }
    return obj;
}




function chechCompressedPubkey(pk_hex) {
    //https://bitcoin.stackexchange.com/questions/3059/what-is-a-compressed-bitcoin-key
    //pk_hex.length == 66  (32bytes)
    if (pk_hex.length == 66 && (pk_hex.startsWith('02') || pk_hex.startsWith('03'))) {
        return true;
    } else {
        return false;
    }
}

//HD seeds import
function app_getHDWalletFromB39mnemonic(words_, password_, passwordHint_) {
    const validate = bitcoin.bip39.validateMnemonic(words_);
    const bip39mnemonic = words_;
    const bip32seed = bitcoin.bip39.mnemonicToSeed(words_, password_)
    if (!validate) {
        bip39mnemonic = null;
        bip32seed = null;
    }
    
    if (!password_) {
        passwordHint_ = "no password";
    }
    if (!passwordHint_) {
        passwordHint_ = "no passwordHint_";
    }
    
    let info = {};
    info['passwordHint'] = passwordHint_;
    info['validate'] = validate;
    info['bip39mnemonic'] = words_;
    info['password_hash'] = buffer2hex(bitcoin.crypto.sha1(password_));
    info['bip39mnemonic_hash'] = buffer2hex(bitcoin.crypto.sha1(words_));
    info['bip32seed_hex_hash'] = buffer2hex(bitcoin.crypto.sha1(buffer2hex(bip32seed)));
    info['passwordHint'] = passwordHint_;
    
    
    this.getInfo = function () {
        return info;
    }
    
    this.getKeypair = function (path) {
        const ret = {};
        try {
            const root = bitcoin.bip32.fromSeed(bip32seed);
            const child = root.derivePath(path);
            ret['publicKey_hex'] = buffer2hex(child.publicKey);
            ret['privateKey_hex'] = buffer2hex(child.privateKey);
            ret['fingerprint'] = buffer2hex(child.fingerprint);
            ret['identifier'] = buffer2hex(child.identifier);
            ret['path'] = path;
            const keyPair = bitcoin.ECPair.fromPrivateKey(child.privateKey);
            ret['privateKey_wif'] = keyPair.toWIF();
            ret['publicKey_hex_1'] = buffer2hex(keyPair.publicKey);
            ret['i'] = {//用来和签名结果一块返回手机，用作检验是否匹配来提示详细的错误如：path 不对，seed 不对，密码不对
                'keypair_path': path,
                'keypair_public_key': buffer2hex(child.publicKey),
                'wallet_mnemonic_check': info['bip39mnemonic_hash'].substring(0, 8),
                'wallet_seed_check': info['bip32seed_hex_hash'].substring(0, 8),
            }
        } catch (e) {
            ret['error'] = e;
        }
        
        if (ret['publicKey_hex_1'] != ret['publicKey_hex'] || ret['publicKey_hex'].length != 66) {
            ret['error'] = 'error keys';
        }
        return ret;
    }
}
//Random keypair
function app_getRandomKeypair() {
    const keyPair = bitcoin.ECPair.makeRandom();
    const address = bitcoin.payments.p2wpkh({ pubkey: keyPair.publicKey });
    const wifPrivateKey = keyPair.toWIF();
    return { "publicKey_hex": buffer2hex(keyPair.publicKey), "privateKey_wif": wifPrivateKey };
}

//HD seeds new
function app_getB39mnemonic(bit) {
    return bitcoin.bip39.generateMnemonic(bit);
}

function app_validateBip39Mnemonic(words_) {
    return bitcoin.bip39.validateMnemonic(words_);
}



var _HDWalletCach = {};

function app_getHDKeypairFromSeedInfoAndPath(parameterJson) {
    var parameterObj = JsonOrBase64parse(parameterJson);
    var loaclHDWalletObj = parameterObj['loaclHDWalletObj'];
    var path = parameterObj['path'];
    
    const HDWallet = new app_getHDWalletFromB39mnemonic(loaclHDWalletObj['words'], loaclHDWalletObj['password'], loaclHDWalletObj['passwordHint']);
    return HDWallet.getKeypair(path);
}


function app_txScriptHexToASM(HexString) {
    const buffer = hex2Buffer(HexString);
    const script = bitcoin.script.decompile(buffer);
    const asm = bitcoin.script.toASM(script);
    return asm;
}

function app_txASMToScriptHex(asm) {
    const scriptSig = bitcoin.script.fromASM(asm);
    return buffer2hex(scriptSig);
}

function app_addressFromASM(asm) {
    const scriptSig = bitcoin.script.fromASM(asm);
    return bitcoin.address.fromOutputScript(scriptSig);
}

function app_addressToASM(address) {
    const script = bitcoin.address.toOutputScript(address);
    const asm = bitcoin.script.toASM(script);
    return asm;
}

function app_sigVerify(parameterJson) {
    var parameterObj = JsonOrBase64parse(parameterJson);
    var message_hex = parameterObj['message_hex'];
    var signature_hex = parameterObj['signature_hex'];
    var pubKey_hex = parameterObj['pubKey_hex'];

    
    const keyPair = bitcoin.ECPair.fromPublicKey(hex2Buffer(pubKey_hex));
    const sigObj = bitcoin.script.signature.decode(hex2Buffer(signature_hex));
    return keyPair.verify(hex2Buffer(message_hex), sigObj['signature']);
}

function app_multiSig_sigUseKey(parameterJson) {
    var parameterObj = JsonOrBase64parse(parameterJson);
    var key = parameterObj['key'];
    var hashHexForSigArray = parameterObj['hashHexForSigArray'];
    
    
    const keyPair = bitcoin.ECPair.fromWIF(key);
    let sigHexArray = [];
    hashHexForSigArray.forEach(function (item) {
                               const hashBuffer = hex2Buffer(item);
                               const sig = bitcoin.script.signature.encode(keyPair.sign(hashBuffer), bitcoin.Transaction.SIGHASH_ALL);
                               sigHexArray.push(buffer2hex(sig));
                               });
    return sigHexArray;
}






//----------------------------------------------------------
function app_generateP2SH_P2WSH_1cltvOf2MultiSig_Address_fromWitnessScriptHex(witnessScriptHex_) {
    const check = parseAndCheck_1cltvOf2MultiSig_witnessScriptAsm(app_txScriptHexToASM(witnessScriptHex_));
    if (check["error"]) {
        return { "error": check["error"] };
    }
    
    let witnessScript = {};
    witnessScript.output = hex2Buffer(witnessScriptHex_);
    const redeemScript = bitcoin.payments.p2wsh({
                                                redeem: witnessScript
                                                })
    
    const scriptPubKey = bitcoin.payments.p2sh({
                                               redeem: redeemScript
                                               })
    const address = bitcoin.address.fromOutputScript(scriptPubKey.output)
    
    const witnessScript_hex = buffer2hex(witnessScript.output);
    const witnessScript_asm = app_txScriptHexToASM(witnessScript_hex);
    
    const redeemScript_hex = buffer2hex(redeemScript.output);
    const redeemScript_asm = app_txScriptHexToASM(redeemScript_hex);
    
    const scriptPubKey_hex = buffer2hex(scriptPubKey.output);
    const scriptPubKey_asm = app_txScriptHexToASM(scriptPubKey_hex);
    
    if (witnessScript_asm && redeemScript_asm && scriptPubKey_asm && address && check) {
        return {
            "P2SH_P2WSH_1cltvOf2MultiSig_address": address,
            "witnessScript": witnessScript_asm,
            "redeemScript": redeemScript_asm,
            "scriptPubKey": scriptPubKey_asm,
            "witnessScript_hex": witnessScript_hex,
            "redeemScript_hex": redeemScript_hex,
            "scriptPubKey_hex": scriptPubKey_hex,
            "lockTimeStamp": check["lockTimeStamp"],
            "lockTimeHex": check["lockTimeHex"],
            "lockTimeDate": check["lockTimeDate"],
            "pubkey1": check["pubkey1"],
            "pubkey2": check["pubkey2"],
        };
    } else {
        return { "error": "error103" };
    }
}


function app_TimeLockMultiSigTxb_getHashHexForSigArray(parameterJson) {
    var parameterObj = JsonOrBase64parse(parameterJson);
    var paymentObj_ = parameterObj;
    const myTimeLockMultiSigTxb = new MyTimeLockMultiSigTxb();
    
    
    
    if (paymentObj_["outputAddressArray"] && paymentObj_["outputValueArray"]) {
        //新的可以随意添加多个输出
        myTimeLockMultiSigTxb.configWithBaseInfo_2(
                                                   paymentObj_["fromAddress"],
                                                   paymentObj_["uTXOsArray"],
                                                   paymentObj_["outputAddressArray"],
                                                   paymentObj_["outputValueArray"],
                                                   paymentObj_["witnessScriptAsm"],
                                                   paymentObj_["value"],
                                                   paymentObj_["fee"],
                                                   paymentObj_["nlockTime"]);
    } else {
        //旧的只能一个输出，自动找零的格式
        myTimeLockMultiSigTxb.configWithBaseInfo(
                                                 paymentObj_["fromAddress"],
                                                 paymentObj_["toAddress"],
                                                 paymentObj_["uTXOsArray"],
                                                 paymentObj_["witnessScriptAsm"],
                                                 paymentObj_["value"],
                                                 paymentObj_["fee"],
                                                 paymentObj_["nlockTime"]);
    }
    
    if (!myTimeLockMultiSigTxb.error() && myTimeLockMultiSigTxb.mutiSigTx() && myTimeLockMultiSigTxb.hashHexForSigArray()) {
        return myTimeLockMultiSigTxb.hashHexForSigArray();
    } else {
        return { "error": myTimeLockMultiSigTxb.error() };
    }
}

function app_TimeLockMultiSigTxb_getSignedTx(parameterJson) {
    
    var parameterObj = JsonOrBase64parse(parameterJson);
    var paymentObj_ = parameterObj['paymentObj_'];
    var sigHexArray_fromKey1_ = parameterObj['sigHexArray_fromKey1_'];
    var sigHexArray_fromKey2_ = parameterObj['sigHexArray_fromKey2_'];
    
    
    
    
    const myTimeLockMultiSigTxb = new MyTimeLockMultiSigTxb();
    
    if (paymentObj_["outputAddressArray"] && paymentObj_["outputValueArray"]) {
        //新的可以随意添加多个输出
        myTimeLockMultiSigTxb.configWithBaseInfo_2(
                                                   paymentObj_["fromAddress"],
                                                   paymentObj_["uTXOsArray"],
                                                   paymentObj_["outputAddressArray"],
                                                   paymentObj_["outputValueArray"],
                                                   paymentObj_["witnessScriptAsm"],
                                                   paymentObj_["value"],
                                                   paymentObj_["fee"],
                                                   paymentObj_["nlockTime"]);
    } else {
        //旧的只能一个输出，自动找零的格式
        myTimeLockMultiSigTxb.configWithBaseInfo(
                                                 paymentObj_["fromAddress"],
                                                 paymentObj_["toAddress"],
                                                 paymentObj_["uTXOsArray"],
                                                 paymentObj_["witnessScriptAsm"],
                                                 paymentObj_["value"],
                                                 paymentObj_["fee"],
                                                 paymentObj_["nlockTime"]);
    }
    myTimeLockMultiSigTxb.fillWitness(sigHexArray_fromKey1_, sigHexArray_fromKey2_);
    const msTx = myTimeLockMultiSigTxb.mutiSigTx();
    const rawTransactionInfo = {
        "tx": msTx.toHex(),
        "txId": msTx.getId(),
        "txHash": msTx.getHash().reverse().toString('hex'),
        "hasWitnesses": msTx.hasWitnesses(),
        "virtualSize": msTx.virtualSize(),
        "byteLength": msTx.byteLength(),
        "inputs": msTx.info_inputs,
        "outputs": msTx.info_outputs,
        "sendValue": msTx.info_sendValue,
        "fee": msTx.info_fee,
        "allInputValue": msTx.info_allInputValue,
        "allOutputValue": msTx.info_allOutputValue,
        "fee_real": msTx.info_fee_real
    };
    
    return rawTransactionInfo;
}

function app_generateP2SH_P2WSH_1cltvOf2MultiSig_Address(parameterJson) {
    
    
    var parameterObj = JsonOrBase64parse(parameterJson);
    var pubkey1_ = parameterObj['pubkey1_'];
    var pubkey2_ = parameterObj['pubkey2_'];
    var lockTimestamp_ = parameterObj['lockTimestamp_'];


    
    const pubkey1 = hex2Buffer(pubkey1_);
    const pubkey2 = hex2Buffer(pubkey2_);
    const now = Math.floor(Date.now() / 1000);
    
    if (lockTimestamp_ - 1537327978 < 0) {
        return { "error": "lockTimestamp_ error." };
    }
    
    // if (lockTimestamp_ - now > 86400 * 365 * 20) {
    //   return { "error": "lockTimestamp_ max time look should be in 20 years." };
    // }
    
    //自带的bip65.ecode有问题。不进行buffer的转换
    //自带的script.number.decode有问题。不支持长于4个字节数据
    //js 自带的 tostring(16) 有问题，不支持自己补全位数。
    //validate-tx测试有问题，超大时间锁，显示负数op_check_locktime_verify4
    //再次改回到 script.number.decode
    //https://bitcoin.stackexchange.com/questions/38378/compact-integer-in-scripts
    //https://github.com/bitcoin/bitcoin/pull/3965
    //https://github.com/bitcoin/bips/blob/master/bip-0065.mediawiki
    //https://github.com/bitcoin/bitcoin/blob/78dae8caccd82cfbfd76557f1fb7d7557c7b5edb/src/script/interpreter.cpp
    // 重点，5个字节的大整数
    
    const lockTime_uint = lockTimestamp_;
    const witnessScript_buffer = bitcoin.script.compile([
                                                         bitcoin.opcodes.OP_IF,
                                                         bitcoin.script.number.encode(lockTime_uint),
                                                         bitcoin.opcodes.OP_CHECKLOCKTIMEVERIFY,
                                                         bitcoin.opcodes.OP_DROP,
                                                         bitcoin.opcodes.OP_ELSE,
                                                         pubkey2,
                                                         bitcoin.opcodes.OP_CHECKSIGVERIFY,
                                                         bitcoin.opcodes.OP_ENDIF,
                                                         pubkey1,
                                                         bitcoin.opcodes.OP_CHECKSIG
                                                         ]);
    return app_generateP2SH_P2WSH_1cltvOf2MultiSig_Address_fromWitnessScriptHex(buffer2hex(witnessScript_buffer));
}
function parseAndCheck_1cltvOf2MultiSig_witnessScriptAsm(witnessScriptAsm) {
    let error_ = null;
    let lockTimeHex = null;
    let lockTimeStamp = null;
    let lockTimeDate = null;
    let pubkey1 = null;
    let pubkey2 = null;
    
    try {
        const array = witnessScriptAsm.split(" ");
        if (array[0] != "OP_IF") {
            error_ = "OP_IF witnessScriptAsm need to be a 2of2 1CLTV multi-signature script 1";
        }
        lockTimeHex = array[1];
        var nlockTime_buf = hex2Buffer(lockTimeHex);
        lockTimeStamp = bitcoin.script.number.decode(nlockTime_buf, 5);
        lockTimeDate = new Date(lockTimeStamp * 1000);
        if (array[2] != "OP_CHECKLOCKTIMEVERIFY") {
            error_ = "OP_CHECKLOCKTIMEVERIFY witnessScriptAsm need to be a 2of2 1CLTV multi-signature script 2";
        }
        if (array[3] != "OP_DROP") {
            error_ = "OP_DROP witnessScriptAsm need to be a 2of2 1CLTV multi-signature script 3";
        }
        
        if (array[4] != "OP_ELSE") {
            error_ = "OP_ELSE witnessScriptAsm need to be a 2of2 1CLTV multi-signature script 3";
        }
        
        if (array[6] != "OP_CHECKSIGVERIFY") {
            error_ = "OP_CHECKSIGVERIFY witnessScriptAsm need to be a 2of2 1CLTV multi-signature script 3";
        }
        
        if (array[9] != "OP_CHECKSIG") {
            error_ = "OP_CHECKSIG witnessScriptAsm need to be a 2of2 1CLTV multi-signature script 3";
        }
        
        pubkey1 = array[8];
        pubkey2 = array[5];
        if (!chechCompressedPubkey(pubkey1) || !chechCompressedPubkey(pubkey2)) {
            error_ = "chechCompressedPubkey witnessScriptAsm need to be a 2of2 1CLTV multi-signature script 3";
        }
        
        
    } catch (e) {
        error_ = "catch error 2of2 1CLTV multi-signature script chech failed" + e;
    }
    return { "error": error_, "lockTimeHex": lockTimeHex, "lockTimeStamp": lockTimeStamp, "lockTimeDate": lockTimeDate, "pubkey1": pubkey1, "pubkey2": pubkey2 };
}
function MyTimeLockMultiSigTxb() {
    var fromAddress_;
    var wifPrivateKey_;
    var toAddress_;
    var outputAddressArray_; //高级功能
    var outputValueArray_; //高级功能
    var uTXOsArray_;
    var witnessScriptAsm_;
    var sendValue_;
    var minerFee_;
    var sig2HexArray_;
    var error_;
    var hashHexForSigArray_;
    var mutiSigTx_;
    var fromAddress_obj_;
    var allInputValue_;
    var allOutputValue_;
    var _inputs = [];
    var _outputs = [];
    
    //多个输出的
    this.configWithBaseInfo_2 = function functionName(fromAddress, uTXOsArray, outputAddressArray, outputValueArray, witnessScriptAsm, sendValue, minerFee, nLockTime) {
        fromAddress_ = fromAddress;
        outputAddressArray_ = outputAddressArray;
        outputValueArray_ = outputValueArray;
        uTXOsArray_ = uTXOsArray;
        witnessScriptAsm_ = witnessScriptAsm;
        sendValue_ = sendValue;// all send value,
        minerFee_ = minerFee;
        
        //检查 witnessScriptAsm 1. 是否是一个 2/2 多签名 2. 是否和 fromAddress 一致的。
        const addressTemp = app_generateP2SH_P2WSH_1cltvOf2MultiSig_Address_fromWitnessScriptHex(app_txASMToScriptHex(witnessScriptAsm_));
        if (addressTemp["error"] || addressTemp.P2SH_P2WSH_1cltvOf2MultiSig_address != fromAddress_) {
            error_ = "fromAddress_ and the witnessScriptAsm_ did not match" + fromAddress_ + addressTemp["error"];
        } else {
            fromAddress_obj_ = addressTemp;
        }
        
        
        //组装 TX
        const witnessScript = hex2Buffer(fromAddress_obj_.witnessScript_hex);
        const redeemScript = hex2Buffer(fromAddress_obj_.redeemScript_hex);
        const msTx = new bitcoin.Transaction();//mutiSigTx
        msTx.locktime = nLockTime;
        allInputValue_ = 0;
        for (var inputIndex = 0; inputIndex < uTXOsArray_.length; inputIndex++) {
            const uTXO = uTXOsArray_[inputIndex];
            const script = uTXO["script"];
            const asm = app_txScriptHexToASM(script)
            const prevOutScript = bitcoin.script.fromASM(asm);
            const tx_hash_big_endian = uTXO["tx_hash_big_endian"];
            const tx_output_n = uTXO["tx_output_n"];
            const value = uTXO["value"];
            const prevOutAddress = bitcoin.address.fromOutputScript(prevOutScript);
            
            allInputValue_ = allInputValue_ + value;
            _inputs.push({ "prev_out": { "hash": tx_hash_big_endian, "index": tx_output_n, "script": script, "script_asm": asm, "address": prevOutAddress, "value": value } })
            msTx.addInput(hex2Buffer(tx_hash_big_endian).reverse(), tx_output_n, 0xfffffffe, bitcoin.script.compile([redeemScript]));
        }
        
        
        
        allOutputValue_ = 0;
        for (var outputIndex = 0; outputIndex < outputAddressArray_.length; outputIndex++) {
            const address = outputAddressArray_[outputIndex];
            const value = outputValueArray_[outputIndex];
            
            const script = bitcoin.address.toOutputScript(address);
            // 检测需要是认识的地址类型和对应的script
            msTx.addOutput(script, value);
            _outputs.push(address + ":" + value);
            allOutputValue_ = allOutputValue_ + value;
        }
        
        hashHexForSigArray_ = [];
        for (var inputIndex = 0; inputIndex < uTXOsArray_.length; inputIndex++) {
            const uTXO = uTXOsArray_[inputIndex];
            const value = uTXO["value"];
            // inputIndex 注意与前面 tx_output_n 的区别。tx_output_n 是指的在 preUTXO 里面的 次序。
            const hash = msTx.hashForWitnessV0(inputIndex, witnessScript, value, bitcoin.Transaction.SIGHASH_ALL);
            hashHexForSigArray_.push(buffer2hex(hash));
        }
        mutiSigTx_ = msTx;
        //补全5条有用数据，数据结构与普通 tx 对齐。
        mutiSigTx_["info_inputs"] = _inputs;
        mutiSigTx_["info_outputs"] = _outputs;
        mutiSigTx_["info_sendValue"] = sendValue_;
        mutiSigTx_["info_fee"] = minerFee_;
        mutiSigTx_["info_allInputValue"] = allInputValue_;
        mutiSigTx_["info_allOutputValue"] = allOutputValue_;
        mutiSigTx_["info_fee_real"] = allInputValue_ - allOutputValue_;
        
        
    }
    
    this.configWithBaseInfo = function (fromAddress, toAddress, uTXOsArray, witnessScriptAsm, sendValue, minerFee, nLockTime) {
        outputAddressArray_ = [];
        outputValueArray_ = [];
        outputAddressArray_.push(toAddress);
        outputValueArray_.push(sendValue);
        
        
        allInputValue_ = 0;
        for (var inputIndex = 0; inputIndex < uTXOsArray.length; inputIndex++) {
            const uTXO = uTXOsArray[inputIndex];
            const value = uTXO["value"];
            allInputValue_ = allInputValue_ + value;
        }
        
        const changeBackValue = allInputValue_ - sendValue - minerFee;
        if (changeBackValue > 0) {
            //找零地址
            outputAddressArray_.push(fromAddress);
            outputValueArray_.push(changeBackValue);
        }
        if (changeBackValue < 0) {
            error_ = "The input value of the transaction is insufficient";
        } else {
            this.configWithBaseInfo_2(fromAddress, uTXOsArray, outputAddressArray_, outputValueArray_, witnessScriptAsm, sendValue, minerFee, nLockTime);
        }
    }
    
    this.fillWitness = function (sig1HexArray, sig2HexArray) {
        //判断如果两组 sigHexArray 都有就是多签名。 如果时间到期就用 sigHexArray_fromKey1。 其他应该返回错误。
        //{key1's signature} {Bob's signature} OP_FALSE
        if (sig1HexArray.length > 0 && sig2HexArray.length > 0) {
            for (var inputIndex = 0; inputIndex < uTXOsArray_.length; inputIndex++) {
                const sig1Hex = sig1HexArray[inputIndex];
                const sig2Hex = sig2HexArray[inputIndex];
                //CRIPT_ERR_MINIMALIF OP_IF/NOTIF argument must be minimal
                const witness1 = [hex2Buffer(sig1Hex), hex2Buffer(sig2Hex), hex2Buffer(""), hex2Buffer(fromAddress_obj_.witnessScript_hex)];
                mutiSigTx_.ins[inputIndex].witness = witness1;
            }
            return;
        }
        
        //{key2's signature} OP_TRUE
        if (sig1HexArray.length > 0 && sig2HexArray.length == 0) {
            for (var inputIndex = 0; inputIndex < uTXOsArray_.length; inputIndex++) {
                const sig1Hex = sig1HexArray[inputIndex];
                //SCRIPT_ERR_MINIMALIF OP_IF/NOTIF argument must be minimal
                const witness1 = [hex2Buffer(sig1Hex), hex2Buffer('01'), hex2Buffer(fromAddress_obj_.witnessScript_hex)];
                mutiSigTx_.ins[inputIndex].witness = witness1;
            }
            return;
        }
    };
    
    this.mutiSigTx = function () {
        return mutiSigTx_;
    };
    
    this.hashHexForSigArray = function () {
        return hashHexForSigArray_;
    };
    
    this.error = function () {
        return error_;
    };
}


/////////利用比特币地址进行签名和认证
function magicHash(message, messagePrefix) {
    messagePrefix = messagePrefix || '\u0018Bitcoin Signed Message:\n'
    if (bitcoin.SafeBuffer.isBuffer(messagePrefix)) {
        messagePrefix = bitcoin.SafeBuffer.from(messagePrefix, 'utf8');
    }
    const messageVISize = bitcoin.varuint.encodingLength(message.length)
    var buffer = bitcoin.SafeBuffer.allocUnsafe(messagePrefix.length + messageVISize + message.length);
    buffer.write(messagePrefix, 0);
    bitcoin.varuint.encode(message.length, buffer, messagePrefix.length)
    buffer.write(message, messagePrefix.length + messageVISize)
    return bitcoin.crypto.hash256(buffer);
}

function encodeSignature(signature, recovery, compressed) {
    if (compressed) recovery += 4
        return bitcoin.SafeBuffer.concat([bitcoin.SafeBuffer.alloc(1, recovery + 27), signature])
        }

function decodeSignature(buffer) {
    if (buffer.length !== 65) throw new Error('Invalid signature length')
        const flagByte = buffer[0] - 27
        if (flagByte > 7) throw new Error('Invalid signature parameter')
            return {
            compressed: !!(flagByte & 4),
            recovery: flagByte & 3,
            signature: buffer.slice(1)
            }
}

function app_bitcoinMessage_sign(parameterJson) {
    var parameterObj = JsonOrBase64parse(parameterJson);
    var message = parameterObj['message'];
    var privateKeyWif = parameterObj['privateKeyWif'];
    var messagePrefix = parameterObj['messagePrefix'];

    
    
    const keyPair = bitcoin.ECPair.fromWIF(privateKeyWif);
    const hash = magicHash(message, messagePrefix);
    const sigObj = bitcoin.secp256k1.sign(hash, keyPair.privateKey);
    const sigBuffer = encodeSignature(sigObj.signature, sigObj.recovery, keyPair.compressed);
    return buffer2Base64(sigBuffer);
}

function app_bitcoinMessage_verify(parameterJson) {
    var parameterObj = JsonOrBase64parse(parameterJson);
    var message = parameterObj['message'];
    var signatureBase64 = parameterObj['signatureBase64'];
    var messagePrefix = parameterObj['messagePrefix'];
    
    
    
    const signature = bitcoin.SafeBuffer.from(signatureBase64, 'base64');
    var parsed = decodeSignature(signature);
    var hash = magicHash(message, messagePrefix);
    var publicKey = bitcoin.secp256k1.recover(hash, parsed.signature, parsed.recovery, parsed.compressed);
    var publicKey_hex = buffer2hex(publicKey);
    var address_p2pkh = bitcoin.payments.p2pkh({ pubkey: publicKey });
    var address_p2wpkh = bitcoin.payments.p2wpkh({ pubkey: publicKey });
    var address_p2sh_p2wpkh;
    if (!address_p2sh_p2wpkh) {
        const witnessScript = bitcoin.payments.p2wpkh({ pubkey: publicKey });
        const witnessScript_asm = app_txScriptHexToASM(buffer2hex(witnessScript.output));
        const scriptPubKey = bitcoin.payments.p2sh({
                                                   redeem: witnessScript
                                                   }).output
        const scriptPubKey_asm = app_txScriptHexToASM(buffer2hex(scriptPubKey));
        const address = bitcoin.address.fromOutputScript(scriptPubKey);
        address_p2sh_p2wpkh = address;
    }
    return {
        'publicKey_hex': publicKey_hex,
        'address_p2pkh': address_p2pkh.address,
        'address_p2wpkh': address_p2wpkh.address,
        'address_p2sh_p2wpkh': address_p2sh_p2wpkh
    };
}

