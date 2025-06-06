class Cwipc < Formula
  desc "CWI point cloud software suite"
  homepage "https://github.com/cwi-dis/cwipc"
  url "https://github.com/cwi-dis/cwipc/releases/download/v7.6.7/cwipc-v7.6.7-source-including-submodules.tar.gz"
  version "7.6.7"
  license "MIT"
  sha256 "a6d6eff54d625f18a35573a669d3709815882f7dec3a0007fb6dbfb999a93e58"
  head "https://github.com/cwi-dis/cwipc.git", branch: "master"
  
  depends_on "cmake" => :build
  depends_on "git-lfs" => :build
  depends_on "nlohmann-json" => :build
  depends_on "jpeg-turbo"
  depends_on "pcl"
  depends_on "python@3.12"
  depends_on "librealsense" => :recommended

  def install
    py_formula = Formula["python@3.12"]
    if build.head?
      # Use normal version-finding scheme
      system "cmake", "-S", ".", "-B", "build", "-DPython3_ROOT_DIR=#{py_formula.opt_prefix}", "-DCWIPC_SKIP_PYTHON_INSTALL=1", *std_cmake_args
    else
      system "cmake", "-S", ".", "-B", "build", "-DPython3_ROOT_DIR=#{py_formula.opt_prefix}", "-DCWIPC_VERSION=#{version}", "-DCWIPC_SKIP_PYTHON_INSTALL=1", *std_cmake_args
    end
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    # Create a venv
    system "#{py_formula.opt_bin}/python3.12", "-m", "venv", "#{libexec}/cwipc/venv"
    # Install a link cwipc_python that points to the venv Python
    ln_sf "../libexec/cwipc/venv/bin/python", "#{bin}/cwipc_python"
    # Install all cwipc packages and dependencies into the venv
    system "#{libexec}/cwipc/venv/bin/python", "-m", "pip", "install", "--find-links", "#{pkgshare}/python", "cwipc_util", "cwipc_codec", "cwipc_realsense2"
    # Copy the cwipc_* scripts to the bin directory. NOTE: this needs to be extended every time a new cwipc_* script is added, because unfortunately nothing here seems to speak wildcards.
    cp "#{libexec}/cwipc/venv/bin/cwipc_forward", "#{bin}"
    cp "#{libexec}/cwipc/venv/bin/cwipc_grab", "#{bin}"
    cp "#{libexec}/cwipc/venv/bin/cwipc_register", "#{bin}"
    cp "#{libexec}/cwipc/venv/bin/cwipc_timing", "#{bin}"
    cp "#{libexec}/cwipc/venv/bin/cwipc_toproxy", "#{bin}"
    cp "#{libexec}/cwipc/venv/bin/cwipc_view", "#{bin}"
    # Run cwipc_view once, so that Python precompiles most needed modules
    system "#{bin}/cwipc_view", "--version"
  end

  test do
    system "#{bin}/cwipc_generate", "1", "#{testpath}"
    assert_match(/\d+\s+\d+\s+\d+\s+.*ply/, shell_output("wc #{testpath}/*.ply").strip)
  end
end
