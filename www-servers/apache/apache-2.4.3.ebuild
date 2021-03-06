# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:  $

EAPI="2"

# latest gentoo apache files
GENTOO_PATCHSTAMP="20120927"
GENTOO_DEVELOPER="patrick"
GENTOO_PATCHNAME="gentoo-apache-2.4.3"

# IUSE/USE_EXPAND magic
IUSE_MPMS_FORK="itk peruser prefork"
IUSE_MPMS_THREAD="event worker"

IUSE_MODULES="actions alias asis auth_basic auth_digest authn_alias authn_anon
authn_dbd authn_dbm authn_default authn_file authz_dbm authz_default
authz_groupfile authz_host authz_owner authz_user autoindex cache cern_meta
charset_lite cgi cgid dav dav_fs dav_lock dbd deflate dir disk_cache dumpio
env expires ext_filter file_cache filter headers ident imagemap include info
log_config log_forensic logio mem_cache mime mime_magic negotiation proxy
proxy_ajp proxy_balancer proxy_connect proxy_ftp proxy_http proxy_scgi rewrite
reqtimeout setenvif speling status substitute unique_id userdir usertrack
version vhost_alias"
# The following are also in the source as of this version, but are not available
# for user selection:
# bucketeer case_filter case_filter_in echo http isapi optional_fn_export
# optional_fn_import optional_hook_export optional_hook_import

# inter-module dependencies
# TODO: this may still be incomplete
MODULE_DEPENDS="
	dav_fs:dav
	dav_lock:dav
	deflate:filter
	disk_cache:cache
	ext_filter:filter
	file_cache:cache
	log_forensic:log_config
	logio:log_config
	mem_cache:cache
	mime_magic:mime
	proxy_ajp:proxy
	proxy_balancer:proxy
	proxy_connect:proxy
	proxy_ftp:proxy
	proxy_http:proxy
	proxy_scgi:proxy
	substitute:filter
"

# module<->define mappings
MODULE_DEFINES="
	auth_digest:AUTH_DIGEST
	authnz_ldap:AUTHNZ_LDAP
	cache:CACHE
	dav:DAV
	dav_fs:DAV
	dav_lock:DAV
	disk_cache:CACHE
	file_cache:CACHE
	info:INFO
	ldap:LDAP
	mem_cache:CACHE
	proxy:PROXY
	proxy_ajp:PROXY
	proxy_balancer:PROXY
	proxy_connect:PROXY
	proxy_ftp:PROXY
	proxy_http:PROXY
	ssl:SSL
	status:STATUS
	suexec:SUEXEC
	userdir:USERDIR
"

# critical modules for the default config
MODULE_CRITICAL="
	authz_host
	dir
	mime
"

inherit apache-2

DESCRIPTION="The Apache Web Server."
HOMEPAGE="http://httpd.apache.org/"
SRC_URI="mirror://apache/httpd/httpd-${PV}.tar.bz2
	http://binhost.ossdl.de/distfiles/${GENTOO_PATCH_A}"

# some helper scripts are Apache-1.1, thus both are here
LICENSE="Apache-2.0 Apache-1.1"
SLOT="2"
KEYWORDS="~alpha amd64 arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE=""

DEPEND="${DEPEND}
	>=dev-libs/openssl-0.9.8x
	apache2_modules_deflate? ( sys-libs/zlib )"

# dependency on >=dev-libs/apr-1.4.5 for bug #368651
RDEPEND="${RDEPEND}
	>=dev-libs/apr-1.4.5
	>=dev-libs/openssl-0.9.8x
	apache2_modules_mime? ( app-misc/mime-types )"

# init script fixup - should be rolled into next tarball #389965
src_prepare() {
	apache-2_src_prepare
	sed -i -e 's/! test -f/test -f/' "${GENTOO_PATCHDIR}"/init/apache2.initd || die "Failed to fix init script"
}

src_install() {
	apache-2_src_install
	for i in /usr/bin/{htdigest,logresolve,htpasswd,htdbm,ab,httxt2dbm}; do
		rm "${D}"/$i || die "Failed to prune apache-tools bits"
	done
	for i in /usr/share/man/man8/{rotatelogs.8,htcacheclean.8}; do
		rm "${D}"/$i || die "Failed to prune apache-tools bits"
	done
	for i in /usr/share/man/man1/{logresolve.1,htdbm.1,htdigest.1,htpasswd.1,dbmmanage.1,ab.1}; do
		rm "${D}"/$i || die "Failed to prune apache-tools bits"
	done
	for i in /usr/sbin/{checkgid,fcgistarter,htcacheclean,rotatelogs}; do
		rm "${D}/"$i || die "Failed to prune apache-tools bits"
	done

	# well, actually installing things makes them more installed, I guess?
	cp "${S}"/support/apxs "${D}"/usr/sbin/apxs || die "Failed to install apxs"
	chmod 0755 "${D}"/usr/sbin/apxs

	ewarn "Make sure you have included in your /etc/apache2/httpd.conf file"
	ewarn "the following (Gentoo's configs need thme):"
	ewarn ""
	ewarn "LoadModule unixd_module modules/mod_unixd.so"
	ewarn "LoadModule authz_core_module modules/mod_authz_core.so"
	ewarn "LoadModule authn_core_module modules/mod_authn_core.so"
}
