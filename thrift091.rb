require "formula"

class Thrift091 < Formula
  homepage "http://thrift.apache.org"

  stable do
    url "http://archive.apache.org/dist/thrift/0.9.1/thrift-0.9.1.tar.gz"
    sha1 "dc54a54f8dc706ffddcd3e8c6cd5301c931af1cc"

    # These patches are 0.9.1-specific and can go away once a newer version is released
    [
     
    ].each do |name, sha|
      patch do
        url "https://git-wip-us.apache.org/repos/asf?p=thrift.git;a=patch;h=#{name}"
        sha1 sha
      end
    end
  end

  bottle do
    cellar :any
    sha1 "07614d7e556b72d53e990de3966b67f8cbea88d6" => :yosemite
    sha1 "983a86c23cc80f40f67c3897dba412e2eb3c0d97" => :mavericks
    sha1 "57e63acf576ff07b549b9f84034d95161cb2c71c" => :mountain_lion
  end

  head do
    url "https://git-wip-us.apache.org/repos/asf/thrift.git"

    depends_on :autoconf
    depends_on :automake
    depends_on :libtool
    depends_on "pkg-config" => :build
    depends_on "bison" => :build
  end

  option "with-haskell", "Install Haskell binding"
  option "with-erlang", "Install Erlang binding"
  option "with-java", "Install Java binding"
  option "with-perl", "Install Perl binding"
  option "with-php", "Install PHP binding"

  depends_on "boost"
  depends_on "openssl"
  depends_on :python => :optional

  def install
    system "./bootstrap.sh" unless build.stable?

    exclusions = ["--without-ruby", "--without-tests", "--without-php_extension"]

    exclusions << "--without-python" if build.without? "python"
    exclusions << "--without-haskell" if build.without? "haskell"
    exclusions << "--without-java" if build.without? "java"
    exclusions << "--without-perl" if build.without? "perl"
    exclusions << "--without-php" if build.without? "php"
    exclusions << "--without-erlang" if build.without? "erlang"

    ENV.cxx11 if MacOS.version >= :mavericks && ENV.compiler == :clang

    # Don't install extensions to /usr:
    ENV["PY_PREFIX"] = prefix
    ENV["PHP_PREFIX"] = prefix

    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--libdir=#{lib}",
                          *exclusions
    ENV.j1
    system "make"
    system "make", "install"
  end

  def caveats
    <<-EOS.undent
    To install Ruby binding:
      gem install thrift

    To install PHP extension for e.g. PHP 5.5:
      brew install homebrew/php/php55-thrift
    EOS
  end
end
