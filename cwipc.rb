# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Cwipc < Formula
  desc "CWI point cloud software suite"
  homepage "https://github.com/cwi-dis/cwipc"
  license "MIT"
  url "https://github.com/cwi-dis/cwipc/releases/download/v7.4/cwipc-v7.4-source-including-submodules.tar.gz"
  sha256 "bcb50a9cda62b6f9fc940453d799636d22101d62ff97712b29922ea81122815e"
  version "7.4"

  depends_on "cmake" => :build
  depends_on "git-lfs" => :build
  depends_on "pcl"
  depends_on "python@3.10"
  depends_on "jpeg-turbo"
  depends_on "librealsense" => :recommended

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    # This is not really okay: it will install the scripts into /usr/local/bin (or /opt equivalent) while they should be in the cellar.
    # Have opened https://github.com/pypa/pip/issues/11253 to see if there is a workaround.
    #system "#{bin}/cwipc_pymodules_install.sh"
    #system Formula["python@3.10"].opt_bin/"pip3", "--verbose", "install", "--upgrade", "--find-links", "#{prefix}/share/cwipc/python", "cwipc_util", "cwipc_codec", "cwipc_realsense2"
    opoo "Please run cwipc_pymodules_install.sh manually to install the Python-based cwipc command line tools"
  end

  test do
    system "#{bin}/cwipc_generate", "1", "#{testpath}"
    assert_match(/\d+\s+\d+\s+\d+\s+.*ply/, shell_output("wc #{testpath}/*.ply").strip)
  end
end
