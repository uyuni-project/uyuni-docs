function selectEn(){

    var str = window.location.pathname;
    var langArray = window.location.pathname.split('/');
    var lenarray = langArray.length;
    var count;
    

    for(var i=0; i<lenarray; i++){

        if(langArray[i] == "es"){

            count = i;
            break;

        }
    }

    
    var lancode = langArray[count];
    

    if(lancode == "es"){
        
        var newURL = str.replace("es","en");
        window.location.href = newURL; 

    }
  

}

function selectEs(){

    var str = window.location.pathname;
    var langArray = window.location.pathname.split('/');
    var lenarray = langArray.length;
    var count;
    

    for(var i=0; i<lenarray; i++){

        if(langArray[i] == "en"){

            count = i;
            break;

        }
    }

    
    var lancode = langArray[count];

   if(lancode == "en"){
        
        var newURL = str.replace("en","es");
        window.location.href = newURL; 

    }
  

}

