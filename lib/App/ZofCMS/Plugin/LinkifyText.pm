package App::ZofCMS::Plugin::LinkifyText;

use warnings;
use strict;

our $VERSION = '0.0101';
use URI::Find::Schemeless;
use HTML::Entities;
use base 'App::ZofCMS::Plugin::Base';

sub _key { 'plug_linkify_text' }
sub _defaults {
    cell => 't',
    key  => 'plug_linkify_text',
    encode_entities => 1,
    new_lines_as_br => 1,
    text => undef,
    callback => sub {
        my $uri = encode_entities $_[0];
        return qq|<a href="$uri">$uri</a>|;
    },
}
sub _do {
    my ( $self, $conf, $t, $q, $config ) = @_;

    if ( ref $conf->{text} eq 'CODE' ) {
        $conf->{text} = $conf->{text}->( $t, $q, $config );
    }

    return
        unless defined $conf->{text}
            and length $conf->{text};

    my $finder = URI::Find::Schemeless->new( $conf->{callback} );

    if ( ref $conf->{text} eq 'ARRAY' ) {
        my @results;
        for ( @{ $conf->{text} } ) {
            if ( $conf->{encode_entities} ) {
                encode_entities $_;
                s/\r?\n/<br>/g
                    if $conf->{new_lines_as_br};
            }

            $finder->find( \$_ );
            
            push @results, { text => $_ };
        }
        $t->{ $conf->{cell} }{ $conf->{key} } = \@results;
    }
    else {
        if ( $conf->{encode_entities} ) {
            encode_entities $conf->{text};
            $conf->{text} =~ s/\r?\n/<br>/g
                if $conf->{new_lines_as_br};
        }

        $finder->find( \ $conf->{text} );

        $t->{ $conf->{cell} }{ $conf->{key} } = $conf->{text};
    }
}

1;
__END__

=head1 NAME

App::ZofCMS::Plugin::LinkifyText - plugin to convert links in plain text into proper HTML <a> elements

=head1 SYNOPSIS

In ZofCMS Template or Main Config File:

    plugins => [
        qw/LinkifyText/,
    ],

    plug_linkify_text => {
        text => qq|http://zoffix.com foo\nbar\nhaslayout.net|,
        encode_entities => 1, # this one and all below are optional; default values are shown
        new_lines_as_br => 1,
        cell => 't',
        key  => 'plug_linkify_text',
        callback => sub {
            my $uri = encode_entities $_[0];
            return qq|<a href="$uri">$uri</a>|;
        },
    },

In HTML::Template template:

    <tmpl_var name='plug_linkify_text'>

=head1 DESCRIPTION

The module is a plugin for L<App::ZofCMS> that provides means convert
URIs found in plain text into proper <a href=""> HTML elements.

This documentation assumes you've read L<App::ZofCMS>, 
L<App::ZofCMS::Config> and L<App::ZofCMS::Template>

=head1 FIRST-LEVEL ZofCMS TEMPLATE AND MAIN CONFIG FILE KEYS

=head2 C<plugins>

    plugins => [
        qw/LinkifyText/,
    ],

B<Mandatory>. You need to include the plugin to the list of plugins to execute.

=head2 C<plug_linkify_text>

    plug_linkify_text => {
        text => qq|http://zoffix.com foo\nbar\nhaslayout.net|,
        encode_entities => 1,
        new_lines_as_br => 1,
        cell => 't',
        key  => 'plug_linkify_text',
        callback => sub {
            my $uri = encode_entities $_[0];
            return qq|<a href="$uri">$uri</a>|;
        },
    },

B<Mandatory>. Takes a hashref as a value; individual keys can be set in 
both Main Config
File and ZofCMS Template, if the same key set in both, the value in ZofCMS 
Template will
take precedence. The following keys/values are accepted:

=head3 C<text>

    plug_linkify_text => {
        text => qq|http://zoffix.com foo\nbar\nhaslayout.net|,
    }
    
    plug_linkify_text => {
        text => [
            qq|http://zoffix.com|,
            qq|foo\nbar\nhaslayout.net|,
        ]
    }
    
    plug_linkify_text => {
        text => sub {
            my ( $t, $q, $config ) = @_;
            return qq|http://zoffix.com foo\nbar\nhaslayout.net|;
        }
    }

B<Mandatory>. Can be set to either a string of text, arrayref of strings
of text or a subref. If value is a subref its C<@_> will contain
(in this order) ZofCMS Template hashref, query parameters hashef and
L<App::ZofCMS::Config> object. The return value will be assigned
to C<text> argument as if it was there originally. C<undef> values will
cause the plugin to stop executing any further. The one string vs. 
arrayref values affect plugin's output format. See C<OUTPUT> section below
for details.

=head3 C<encode_entities>

    plug_linkify_text => {
        text => qq|http://zoffix.com foo\nbar\nhaslayout.net|,
        encode_entities => 1,
    }

B<Optional>. Takes either true or false values. When set to a true
value, plugin will encode HTML entities in the provided text before
processing URIs. B<Defaults to:> C<1>

=head3 C<new_lines_as_br>

    plug_linkify_text => {
        text => qq|http://zoffix.com foo\nbar\nhaslayout.net|,
        new_lines_as_br => 1,
    }

B<Optional>. Applies only when C<encode_entities> (see above) is set
to a true value. Takes either true or false values. When set to
a true value, the plugin will convert anything that matches C</\r?\n/>
into HTML <br> element. B<Defaults to:> C<1>

=head3 C<cell>

    plug_linkify_text => {
        text => qq|http://zoffix.com foo\nbar\nhaslayout.net|,
        cell => 't',
    }

B<Optional>. Takes a literal string as a value. Specifies the name
of the B<first-level> key in ZofCMS Template hashref into which to put
the result; this key must point to either an undef value or a hashref.
See C<key> argument below as well.
B<Defaults to:> C<t>

=head3 C<key>

    plug_linkify_text => {
        text => qq|http://zoffix.com foo\nbar\nhaslayout.net|,
        key  => 'plug_linkify_text',
    }

B<Optional>. Takes a literal string as a value. Specifies the name
of the B<second-level> key that is inside C<cell> (see above) key - 
plugin's output will be stored into this key.
B<Defaults to:> C<plug_linkify_text>

=head3 C<callback>

    plug_linkify_text => {
        text => qq|http://zoffix.com foo\nbar\nhaslayout.net|,
        callback => sub {
            my $uri = encode_entities $_[0];
            return qq|<a href="$uri">$uri</a>|;
        },
    },

B<Optional>. Takes a subref as a value. This subref will be used
as the "callback" sub in L<URI::Find::Schemeless>'s C<find()> method.
See L<URI::Find::Schemeless> for details. B<Defaults to:>

    sub {
        my $uri = encode_entities $_[0];
        return qq|<a href="$uri">$uri</a>|;
    },

=head1 OUTPUT

    $VAR1 = {
        't' => 'plug_linkify_text' => '<a href="http://zoffix.com/">http://zoffix.com/</a>'
    };

    $VAR1 = {
        't' => 'plug_linkify_text' => [
            { text => '<a href="http://zoffix.com/">http://zoffix.com/</a>' },
            { text => '<a href="http://zoffix.com/">http://zoffix.com/</a>' },
    };

Depending on whether C<text> plugin's argument is set to a string
or an arrayref of strings, the plugin will set the C<key> key under C<cell>
first-level key to either a converted string or an arrayref of hashrefs
respectively. Each hashref will have only one key - C<text> - value
of which is the converted text (thus you can use this arrayref
directly in C<< <tmpl_loop> >>).

=head1 AUTHOR

'Zoffix, C<< <'zoffix at cpan.org'> >>
(L<http://haslayout.net/>, L<http://zoffix.com/>, L<http://zofdesign.com/>)

=head1 BUGS

Please report any bugs or feature requests to C<bug-app-zofcms-plugin-linkifytext at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=App-ZofCMS-Plugin-LinkifyText>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::ZofCMS::Plugin::LinkifyText

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=App-ZofCMS-Plugin-LinkifyText>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/App-ZofCMS-Plugin-LinkifyText>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/App-ZofCMS-Plugin-LinkifyText>

=item * Search CPAN

L<http://search.cpan.org/dist/App-ZofCMS-Plugin-LinkifyText/>

=back



=head1 COPYRIGHT & LICENSE

Copyright 2009 'Zoffix, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

