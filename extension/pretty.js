var frameTemplate;
frameTemplate = '<html><head></head><body class="json-parse">{{{ contents }}}</body></html>';

var errorTemplate;
errorTemplate = '<h1>Crap, you got an error.</h1>';
errorTemplate += '<h2>Here\'s what the server says: </h2><div class="message">{{{ error_message }}}</div>';
errorTemplate += '<h2>Here\'s where the error occurred:</h2> <div class="message">{{ exception.file }}:{{ exception.line }}</div>';
errorTemplate += '<h2>No Help? Here the raw error: </h2> {{{ raw }}}';

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
    var frame = Handlebars.compile(frameTemplate);
    if (message.hasOwnProperty('error')) {
        var template = Handlebars.compile(errorTemplate);

        document.body.className = 'json-parse error';
        message.raw = document.body.innerHTML;

        message.error_message = nl2br(message.error_message);
        var contents = template(message);

        document.body.innerHTML = frame({"contents": contents});
    }
}

function nl2br (str, is_xhtml) {
    var breakTag = (is_xhtml || typeof is_xhtml === 'undefined') ? '<br />' : '<br>';
    return (str + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + breakTag + '$2');
}