class Po4a < Formula
  homepage "http://po4a.alioth.debian.org/"
  url "https://alioth.debian.org/frs/download.php/file/4176/po4a-0.48.tar.gz"
  sha256 "a89595ca42e896c97ce4ffc231a075cc88692216b4bc05df40414d7428c4286c"

  depends_on "gettext" => :build
  depends_on "docbook"
  depends_on "docbook-xsl"

  resource "Module::Build" do
    url "https://cpan.metacpan.org/authors/id/L/LE/LEONT/Module-Build-0.4220.tar.gz"
    mirror "https://cpan.metacpan.org/authors/id/L/LE/LEONT/Module-Build-0.4220.tar.gz"
    sha256 "fb1207c7e799366f7a8adda3f135bf8141c4d6068505650d4db2b2d3ce34b5a2"
  end

  resource "Pod::Man" do
    url "http://search.cpan.org/CPAN/authors/id/R/RR/RRA/podlators-4.07.tar.gz"
    mirror "http://search.cpan.org/CPAN/authors/id/R/RR/RRA/podlators-4.07.tar.gz"
    sha256 "a995ff7af4a8f835a44c6e66301e1afd8712f892996b1ae7398de2038f66a781"
  end

  resource "Locale::Gettext" do
    url "http://search.cpan.org/CPAN/authors/id/P/PV/PVANDRY/gettext-1.07.tar.gz"
    mirror "http://search.mcpan.org/CPAN/authors/id/P/PV/PVANDRY/gettext-1.07.tar.gz"
    sha256 "909d47954697e7c04218f972915b787bd1244d75e3bd01620bc167d5bbc49c15"
  end

  #resource "SGMLS" do
  #  url "http://search.cpan.org/CPAN/authors/id/R/RA/RAAB/SGMLSpm-1.1.tar.gz"
  #  mirror "http://search.mcpan.org/CPAN/authors/id/R/RA/RAAB/SGMLSpm-1.1.tar.gz"
  #  sha1 "31d4199d71d5d809f5847bac594c03348c82e2e2"
  #end

  resource "Text::WrapI18N" do
    url "http://search.cpan.org/CPAN/authors/id/K/KU/KUBOTA/Text-WrapI18N-0.06.tar.gz"
    mirror "http://search.mcpan.org/CPAN/authors/id/K/KU/KUBOTA/Text-WrapI18N-0.06.tar.gz"
    sha256 "4bd29a17f0c2c792d12c1005b3c276f2ab0fae39c00859ae1741d7941846a488"
  end

  resource "Unicode::GCString" do
    url "http://www.cpan.org/authors/id/N/NE/NEZUMI/Unicode-LineBreak-2016.003.tar.gz"
    mirror "http://search.mcpan.org/CPAN/authors/id/N/NE/NEZUMI/Unicode-LineBreak-2016.003.tar.gz"
    sha256 "e64e2d990a8cc90f8a387866509c35a93c50b812f5a2e60f3d9deb947a71dc24"
  end

  def install
    ENV.prepend_create_path "PERL5LIB", libexec+"lib/perl5"
    #ENV.prepend_create_path "PERLLIB", '/usr/local/lib/perl5'  # for SGMLS
    ENV.delete "XML_CATALOG_FILES"
    ENV.prepend_path "XML_CATALOG_FILES", etc+"/catalog"
    print ENV["XML_CATALOG_FILES"]

    resources.each do |r|
      r.stage do
        system "perl", "Makefile.PL", "INSTALL_BASE=#{libexec}"
        system "make", "install"
      end
    end

    %w[po4a po4a-gettextize po4a-normalize po4a-translate po4a-updatepo].each do |f|
      chmod 0644, f  # FIXME
      inreplace f, "use warnings", "use warnings;\nuse lib '#{lib}/perl5/site_perl';"
    end
    system "perl", "Build.PL", "--prefix", prefix
    system "./Build"
    system "./Build", "install"

    bin.env_script_all_files(libexec+"bin", "PERL5LIB" => ENV["PERL5LIB"])
  end

  test do
    system bin/"po4a", "--version"
    system bin/"po4a-build", "--version"
    system bin/"po4a-gettextize", "--version"
    system bin/"po4a-normalize", "--version"
    system bin/"po4a-translate", "--version"
    system bin/"po4a-updatepo", "--version"
    system bin/"po4aman-display-po", "-h"
    system bin/"po4apod-display-po", "-h"
  end
end
