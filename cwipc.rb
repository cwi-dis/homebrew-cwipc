class Cwipc < Formula
  desc "CWI point cloud software suite"
  homepage "https://github.com/cwi-dis/cwipc"
  url "https://github.com/cwi-dis/cwipc/releases/download/v8.0.0/cwipc-fullsource-v8.0.0.tar.gz"
  sha256 "5df60f42acc220df5df8ffc652719e7d062d9765f84f1b180cefea74a83a9189"
  license "MIT"
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
    system "bash", "scripts/install-orbbecsdk-macos.sh"
    if build.head?
      # Use normal version-finding scheme
      system "cmake", "-S", ".", "-B", "build", \
        "-DPython3_ROOT_DIR=#{py_formula.opt_prefix}", \
        *std_cmake_args
    else
      system "cmake", "-S", ".", "-B", "build", \
        "-DPython3_ROOT_DIR=#{py_formula.opt_prefix}", \
        "-DCWIPC_VERSION=#{version}", \
        *std_cmake_args
    end
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    # Create a venv
    system "#{py_formula.opt_bin}/python3.12", "-m", "venv", "#{libexec}/cwipc/venv"
    # Install a link cwipc_python that points to the venv Python
    ln_sf "../libexec/cwipc/venv/bin/python", "#{bin}/cwipc_python"
    # Install a version of rpds-py that doesn't have the --headerpad problem
    # Issue reported as https://github.com/crate-py/rpds/issues/200
    system "#{libexec}/cwipc/venv/bin/python", "-m", "pip", "install", "rpds-py==0.27.1"
    # Install all cwipc packages and dependencies into the venv
    system "#{libexec}/cwipc/venv/bin/python", "-m", "pip", "install", \
      "--find-links", "#{pkgshare}/python", \
      "cwipc_util", "cwipc_codec", "cwipc_realsense2", "cwipc_orbbec"
    # Remove a faulty libomp installed by open3d.
    rm "#{libexec}/cwipc/venv/lib/python3.12/site-packages/open3d/libomp.dylib"
    # Copy the cwipc_* scripts to the bin directory.
    # NOTE: this needs to be extended every time a new cwipc_* script is added,
    # because unfortunately nothing here seems to speak wildcards.
    cp "#{libexec}/cwipc/venv/bin/cwipc", bin.to_s
    cp "#{libexec}/cwipc/venv/bin/cwipc_forward", bin.to_s
    cp "#{libexec}/cwipc/venv/bin/cwipc_grab", bin.to_s
    cp "#{libexec}/cwipc/venv/bin/cwipc_register", bin.to_s
    cp "#{libexec}/cwipc/venv/bin/cwipc_timing", bin.to_s
    cp "#{libexec}/cwipc/venv/bin/cwipc_toproxy", bin.to_s
    cp "#{libexec}/cwipc/venv/bin/cwipc_view", bin.to_s
    # Run cwipc_view once, so that Python precompiles most needed modules
    system "#{bin}/cwipc", "view", "--version"
  end

  test do
    system "#{bin}/cwipc_generate", "1", testpath.to_s
    assert_match(/\d+\s+\d+\s+\d+\s+.*ply/, shell_output("wc #{testpath}/*.ply").strip)
  end
end
