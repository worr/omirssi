use warnings;
use strict;

use Irssi;
use WWW::Omegle;

use vars qw($VERSION %IRSSI);

$VERSION = '0.10';
%IRSSI = (
    authors =>  "William Orr",
    contact =>  "will\@worrbase.com",
    name    =>  "Omirssi",
    description => "Omegle!",
    license =>  "MIT License",
);

# The Omegle perl module is so incomplete, that this is necessary
$SIG{__WARN__} = sub {};

my $window;
my $om = WWW::Omegle->new(on_chat => \&stranger_chat,
                          on_disconnect => sub { 
                              $window->print("Stranger disconnected"); });
my $stranger = "Stranger";
my $timeout;


sub om_poke {
    $om->poke;
}

sub stranger_chat {
    my ($omegle, $message) = @_;

    $window->print("$stranger: $message", MSGLEVEL_CLIENTCRAP);
}

sub om_connect {
    if ($om->start) {
        $window->print("Now talking with a total stranger");
        $timeout = Irssi::timeout_add(500, \&om_poke, '');
    } else {
        $window->print("Omegle connect failed!");
    }
}

sub om_disconnect {
    if ($om->disconnect) {
        $window->print("Disconnected from Omegle chat");
        Irssi::timeout_remove($timeout);
    } else {
        $window->print("Failure disconnecting");
        Irssi::timeout_remove($timeout);
    }
}

sub om_say {
    my ($message) = @_;

    $om->say("$message");
    $window->print("You: $message", MSGLEVEL_CLIENTCRAP);
}

sub om_rename {
    unless (@_ == 1) {
        $window->print("/om_rename name");
        return;
    }

    $stranger = shift;
}

$window = Irssi::window_find_name('omegle');

if (!$window) {
    Irssi::active_win()->print("Couldn't find a window called omegle, creating...");
    $window = Irssi::Windowitem::window_create('omegle', 1);
    $window->set_name('omegle');
}

if ($window) {
    Irssi::command_bind(om_connect => \&om_connect);
    Irssi::command_bind(om_disconnect => \&om_disconnect);
    Irssi::command_bind(om_say => \&om_say);
    Irssi::command_bind(om_rename => \&om_rename);
} else {
    Irssi::active_win()->print("Couldn't create window, create a window yourself " .
                               "and call it omegle.");
}
