use strict;
use warnings;
use utf8;

use Amon2::Lite;
use Digest::MD5 ();

get '/' => sub {
    my $c = shift;
    return $c->render('index.tt');
};

my $clients = {};

any '/emacs' => sub {
    my ($c) = @_;
    my $id = Digest::SHA1::sha1_hex(rand() . $$ . {} . time);

    $c->websocket(sub {
        my $ws = shift;
        $clients->{$id} = $ws;

        $ws->on_receive_message(sub {
            my ($c, $message) = @_;
            for (keys %$clients) {
                $clients->{$_}->send_message(
                    "Emacs: $message"
                );
            }
        });
        $ws->on_eof(sub {
            my ($c) = @_;
            delete $clients->{$id};
        });
        $ws->on_error(sub {
            my ($c) = @_;
            delete $clients->{$id};
        });
    });
};

any '/chat' => sub {
    my ($c) = @_;
    my $id = Digest::SHA1::sha1_hex(rand() . $$ . {} . time);

    $c->websocket(sub {
        my $ws = shift;
        $clients->{$id} = $ws;

        $ws->on_receive_message(sub {
            my ($c, $message) = @_;
            for (keys %$clients) {
                $clients->{$_}->send_message(
                    "Chrome: $message"
                );
            }
        });
        $ws->on_eof(sub {
            my ($c) = @_;
            delete $clients->{$id};
        });
        $ws->on_error(sub {
            my ($c) = @_;
            delete $clients->{$id};
        });
    });
};

# load plugins
__PACKAGE__->load_plugin('Web::WebSocket');
__PACKAGE__->enable_middleware('AccessLog');
__PACKAGE__->enable_middleware('Lint');

__PACKAGE__->to_app(handle_static => 1);

__DATA__

__DATA__

@@ index.tt
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <title>WS</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script type="text/javascript" src="/static/jquery.min.js"></script>
    <link rel="stylesheet" href="/static/bootstrap.min.css">
    <style>
    .container { padding: 0 0 0 50px;}
    </style>
</head>
<body>
    <div class="container">
        <header><h1>sample</h1></header>
        <section class="row">
            <form id="form">
                <input type="text" name="message" id="message">
                <input type="submit">
            </form>
            <pre id="log"></pre>
        </section>
        <footer>Powered by <a href="http://amon.64p.org/">Amon2::Lite</a></footer>
    </div>
    <script type="text/javascript">
        function log(msg) {
            $('#log').text($('#log').text() + msg + "\n");
        }

        $(function () {
            var ws = new WebSocket('ws://localhost:5000/chat');
            ws.onopen = function () {
                log('connected');
            };
            ws.onclose = function (ev) {
                log('closed');
            };
            ws.onmessage = function (ev) {
                log(ev.data);
                $('#message').val('');
            };
            ws.onerror = function (ev) {
                console.log(ev);
                log('error: ' + ev.data);
            };
            $('#form').submit(function () {
                ws.send($('#message').val());
                return false;
            });
        });
    </script>
</body>
</html>
