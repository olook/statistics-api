log_event = function(type, subject, data) {
  if(typeof $skip_log_event !== 'undefined' && $skip_log_event) {
    return;
  }

	// Avoid hiting the stats server with dev and staging data.
	if(window.location.host != 'www.olook.com.br') {
		return;
	}

	var visitorId = getCookie('visitorId');
	if (visitorId == undefined) {
		visitorId = makeid();
		setCookie('visitorId', visitorId);
	}

	var request = new XMLHttpRequest();

	var log = {visitor_id: visitorId, type: type, subject: subject};

	if (data != undefined) {
		log.data = data;
	}

	var str_json = JSON.stringify(log);
	try {
		request.open("POST", "http://stats.olook.com.br", false);
		request.setRequestHeader("Content-type", "application/json");
		request.send(str_json);
	} catch (ex) {
		// console.log(ex);
	}
}

function setCookie(name, value) { 
	var exdays=5;
	var expires;
	var date; 
	var value;

	date = new Date(); //  criando o COOKIE com a data atual
	date.setTime(date.getTime()+(exdays*24*60*60*1000));
	expires = date.toUTCString();
	document.cookie = name+"="+value+"; expires="+expires+"; path=/";
}

function getCookie(name) {
  var value = "; " + document.cookie;
  var parts = value.split("; " + name + "=");
  if (parts.length == 2) return parts.pop().split(";").shift();
}

function makeid() {
	var size=30;
    var text = "";
    var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

    for( var i=0; i < size; i++ )
        text += possible.charAt(Math.floor(Math.random(new Date()) * possible.length));

    return text;
}
