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
    pyFormula = Formula["python@3.10"]
    system "cmake", "-S", ".", "-B", "build", "-DPython3_ROOT_DIR=#{pyFormula.opt_prefix}", "-DCWIPC_VERSION=#{version}", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    # Install a link cwipc_python that points to the Python used to install
    ln_sf pyFormula.opt_bin/"python3.10", "#{prefix}/bin/cwipc_python"
    opoo "Please run cwipc_pymodules_install.sh manually to install the Python-based cwipc command line tools"
  end

  test do
    system "#{bin}/cwipc_generate", "1", "#{testpath}"
    assert_match(/\d+\s+\d+\s+\d+\s+.*ply/, shell_output("wc #{testpath}/*.ply").strip)
  end
end
