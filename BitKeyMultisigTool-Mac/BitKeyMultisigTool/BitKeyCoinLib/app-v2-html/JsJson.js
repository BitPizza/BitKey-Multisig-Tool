function JsonStringFy(obj){
//    return JSON.stringify(obj).replace(/'/g, "\\'");
    
    return JSON.stringify(obj);

}

function BeJson(string){
    return JSON.parse(string);
}


