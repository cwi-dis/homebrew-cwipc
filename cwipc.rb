class Cwipc < Formula
  desc "CWI point cloud software suite"
  homepage "https://github.com/cwi-dis/cwipc"
  url "https://github.com/cwi-dis/cwipc/releases/download/v7.5.3/cwipc-v7.5.3-source-including-submodules.tar.gz"
  version "7.5.3"
  license "MIT"
  sha256 "d24d5b0b95b926c2f28e90f01bd1b31e09116c06163d6693232c934999fdcd0d"
  head "https://github.com/cwi-dis/cwipc.git", branch: "master"
  
  depends_on "cmake" => :build
  depends_on "git-lfs" => :build
  depends_on "nlohmann-json" => :build
  depends_on "jpeg-turbo"
  depends_on "pcl"
  depends_on "python@3.11"
  depends_on "librealsense" => :recommended

  def install
    py_formula = Formula["python@3.11"]
    if build.head?
      # Use normal version-finding scheme
      system "cmake", "-S", ".", "-B", "build", "-DPython3_ROOT_DIR=#{py_formula.opt_prefix}", "-DCWIPC_SKIP_PYTHON_INSTALL=1", *std_cmake_args
    else
      system "cmake", "-S", ".", "-B", "build", "-DPython3_ROOT_DIR=#{py_formula.opt_prefix}", "-DCWIPC_VERSION=#{version}", "-DCWIPC_SKIP_PYTHON_INSTALL=1", *std_cmake_args
    end
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    # Install a link cwipc_python that points to the Python used to install
    ln_sf py_formula.opt_bin/"python3.11", "#{bin}/cwipc_python"
    # Hack to make cwipc prefix directory a valid destination for pip installs
    #system "mkdir", "-p", "#{prefix}/lib/python3.11"
    #system "mkdir", "-p", "#{prefix}/lib/python3.11/site-packages"
    #system "ls", "-lRa", "#{prefix}/"
    system "#{bin}/cwipc_python", "-m", "pip", "--verbose", "install", "--prefix", prefix, "--upgrade", "--find-links", "#{pkgshare}/python", "cwipc_util", "cwipc_codec", "cwipc_realsense2"
  end

  test do
    system "#{bin}/cwipc_generate", "1", "#{testpath}"
    assert_match(/\d+\s+\d+\s+\d+\s+.*ply/, shell_output("wc #{testpath}/*.ply").strip)
  end
end
