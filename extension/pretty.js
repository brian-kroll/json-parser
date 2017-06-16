
var errorTemplate = '<h1>Crap, you got an error.</h1><p>Here\'s what the server says: <div class="message">{{ message }}</div></p>';
try {
    messageObject = JSON.parse(document.body.textContent);

    buildDocument(messageObject);
}
catch (exception) {
    console.log(exception);
}
function buildDocument(messageObject) {
    if (messageObject.hasOwnProperty('error')) {
        var template = Handlebars.compile(errorTemplate);
        var ret = template({"message": messageObject.error_message});
        document.body.className = 'error';

        document.body.innerHTML = ret;
    }
}
