var errorTemplate;
errorTemplate = '<h1>Crap, you got an error.</h1>';
errorTemplate += '<p>Here\'s what the server says: <div class="message">{{ error_message }}</div></p>';
errorTemplate += '<p>Here\'s where the error occurred: <div class="message">{{ exception.file }}</div>';
errorTemplate += '<p>No Help? Here the raw error: {{ raw }}</p>';

var speedometer = '<canvas id="tutorial" width="440" height="220">';
speedometer += 'Canvas not available.';
speedometer += '</canvas>';

try {
    messageObject = JSON.parse(document.body.textContent);

    buildDocument(messageObject);
}
catch (exception) {
    console.log(exception);
}


function buildDocument(message) {
    if (message.hasOwnProperty('error')) {
        var template = Handlebars.compile(errorTemplate);

        document.body.className = 'error';
        message.raw = document.body.innerHTML;
        document.body.innerHTML = template(message);
    }
}
