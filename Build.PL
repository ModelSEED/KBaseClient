#!/usr/bin/env perl

use Module::Build;
Module::Build->new(
    module_name => 'Bio::KBase::Auth',
    license     => 'perl',
    requires => {
        'parent' => undef,
		'Exception::Class' => undef,
		'Params::Validate' => undef,
		'JSON' => 2.53,
        'Digest::SHA1' => 2.13,
        'Crypt::OpenSSL::RSA' => 0.28,
        'Convert::PEM' => 0.08,
        'MIME::Base64' => 3.08,
        'HTTP::Request' => 6.00,
        'HTTP::Daemon' => 6.00,
        'LWP::UserAgent' => 6.02,
        'LWP::Protocol::https' => 1.0,
        'URI' => 1.37,
        'URI::URL' => 1.0,
        'Test::More' => 0.94,
        'POSIX' => 1.0,
        'Exporter' => undef,
        'Getopt::Long::Descriptive' => undef,
        'Text::Table' => undef,
        'JSON::RPC::Client' => undef,
        'Config::Simple' => undef,
        'Object::Tiny::RW' => undef,
        'Term::ReadKey' => undef
    },
    dist_abstract => 'Client scripts for FBA and workspace',
)->create_build_script;
