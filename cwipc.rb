# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Cwipc < Formula
  desc "CWI point cloud software suite"
  homepage "https://github.com/cwi-dis/cwipc"
  license "MIT"
  url "https://github.com/cwi-dis/cwipc/releases/download/v7.4.2/cwipc-v7.4.2-source-including-submodules.tar.gz"
  sha256 "bdeac677569cb71c91e247e1182cb297fe7d86cdbf845caa00da8f68f42544e5"
  head "https://github.com/cwi-dis/cwipc.git"
  # version "7.4.1"

  depends_on "cmake" => :build
  depends_on "git-lfs" => :build
  depends_on "pcl"
  depends_on "python@3.10"
  depends_on "jpeg-turbo"
  depends_on "librealsense" => :recommended

  def install
    pyFormula = Formula["python@3.10"]
    if build.head?
      # Use normal version-finding scheme
      system "cmake", "-S", ".", "-B", "build", "-DPython3_ROOT_DIR=#{pyFormula.opt_prefix}", "-DCWIPC_SKIP_PYTHON_INSTALL=1", *std_cmake_args
    else
      system "cmake", "-S", ".", "-B", "build", "-DPython3_ROOT_DIR=#{pyFormula.opt_prefix}", "-DCWIPC_VERSION=#{version}", "-DCWIPC_SKIP_PYTHON_INSTALL=1", *std_cmake_args
    end
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    # Install a link cwipc_python that points to the Python used to install
    ln_sf pyFormula.opt_bin/"python3.10", "#{prefix}/bin/cwipc_python"
    # Hack to make cwipc prefix directory a valid destination for pip installs
    system "mkdir", "-p", "#{prefix}/lib/python3.10/site-packages"
    system pyFormula.opt_bin/"python3.10", "-m", "pip", "--verbose", "install", "--prefix", prefix, "--upgrade", "--find-links", "#{prefix}/share/cwipc/python", "cwipc_util", "cwipc_codec", "cwipc_realsense2"

  end

  test do
    system "#{bin}/cwipc_generate", "1", "#{testpath}"
    assert_match(/\d+\s+\d+\s+\d+\s+.*ply/, shell_output("wc #{testpath}/*.ply").strip)
  end
end
