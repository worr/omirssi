# omirssi.pl
#
# How to use
# ----------
#
# /om_connect - start a chat with a stranger
# /om_disconnect - stop a chat
# /om_say - send a message
# /om_rename - rename the user
#

use warnings;
use strict;

use Irssi;
use WWW::Omegle;

use vars qw($VERSION %IRSSI);

$VERSION = '0.11';
%IRSSI = (
    authors =>  "William Orr",
    contact =>  "will\@worrbase.com",
    name    =>  "Omirssi",
    description => "Omegle on irssi!",
    license =>  "MIT License",
);

# Let's add some configurability...
Irssi::settings_add_str('omirssi', 'stranger_name', 'Stranger');
Irssi::settings_add_str('omirssi', 'your_name', 'You');
Irssi::settings_add_str('omirssi', 'omirssi_window_prefix', 'omegle');
Irssi::settings_add_str('omirssi', 'connect_message', '');
Irssi::settings_add_str('omirssi', 'disconnect_message', '');
Irssi::settings_add_bool('omirssi', 'warn_messages', 0);

# The Omegle perl module is so incomplete, that this is necessary
if (not Irssi::settings_get_bool('warn_messages')) {
    $SIG{__WARN__} = sub {};
}

my $window;
my $om = WWW::Omegle->new(on_chat => \&stranger_chat,
                          on_disconnect => sub { 
                              $window->print("Stranger disconnected"); 
                          });
my $stranger = Irssi::settings_get_str('stranger_name');
my $timeout;
my $window_prefix = Irssi::settings_get_str('omirssi_window_prefix');
my $you = Irssi::settings_get_str('your_name');

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
    $window->print("$you: $message", MSGLEVEL_CLIENTCRAP);
}

sub om_rename {
    unless (@_ == 3) {
        $window->print("/om_rename name", MSGLEVEL_CLIENTCRAP);
        return;
    }

    $stranger = shift;
}

$window = Irssi::window_find_name($window_prefix);

if (!$window) {
    Irssi::active_win()->print("Couldn't find a window called $window_prefix, creating...");
    $window = Irssi::Windowitem::window_create($window_prefix, 1);
    $window->set_name($window_prefix);
}

if ($window) {
    # Command bindings
    Irssi::command_bind(om_connect => \&om_connect);
    Irssi::command_bind(om_disconnect => \&om_disconnect);
    Irssi::command_bind(om_say => \&om_say);
    Irssi::command_bind(om_rename => \&om_rename);
} else {
    Irssi::active_win()->print("Couldn't create window, create a window yourself " .
                               "and call it $window_prefix.");
}
