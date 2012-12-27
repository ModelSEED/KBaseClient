package Bio::KBase::Auth;
#
# Common information across the apps
#
# sychan 4/24/2012
use strict;

$Bio::KBase::Auth::AuthSvcHost = "https://nexus.api.globusonline.org/";
$Bio::KBase::Auth::AuthorizePath = "/goauth/token";
$Bio::KBase::Auth::ProfilePath = "users";
$Bio::KBase::Auth::RoleSvcURL = "https://kbase.us/services/authorization/Roles";

our $VERSION = '0.5.1';

1;

__END__
=pod

=head1 Bio::KBase::Auth

OAuth based authentication for Bio::KBase::* libraries.

This is a helper class that stores shared configuration information.

=head2 Class Variables

=over

=item B<$Bio::KBase::Auth::AuthSvcHost>

   This variable contains a URL that points to the authentication service that stores
user profiles. If this is not set properly, the libraries will be unable to reach
the centralized user database and authentication will not work at all.


=item B<$VERSION>

   The version of the libraries.

=item B<$Bio::KBase::Auth::AuthorizePath>

   This variable contains the path on the AuthSvcHost where token authorization
requests are posted.

=item B<$Bio::KBase::Auth::ProfilePath>

   This variable contains the path on the AuthSvcHost where user profile queries
are sent

=item B<$Bio::KBase::Auth::RoleSvcURL>

   The URL for the Roles service, used to retrieve the roles/groups that a user
is associated with.


=item B<$VERSION>

   The version of the libraries.

=back

=cut

