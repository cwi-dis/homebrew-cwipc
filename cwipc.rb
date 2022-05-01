# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Cwipc < Formula
  desc "xxxjack description goes here"
  homepage "https://github.com/cwi-dis/cwipc"
  license "MIT"
  url "https://github.com/cwi-dis/cwipc.git",
    tag: "exp-jack-release-1",
    revision: "f2eeafe4670d9a5ae7b8a51c0cf7e9d70749c9fa"
  version "exp-jack-release-1"

  depends_on "cmake" => :build
  depends_on "git-lfs" => :build
  depends_on "pcl"
  depends_on "python3@3.9"
  depends_on "jpeg-turbo"
  depends_on "librealsense" => :recommended

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    # xxxjack need to do:
    # /opt/homebrew/opt/python@3.9/bin/python3 -m pip install --prefix /opt/homebrew/opt/cwipc --find-links /opt/homebrew/opt/cwipc/share/cwipc/python cwipc_util cwipc_codec cwipc_realsense2
  end

  test do
    system "#{bin}/cwipc_generate", "1", "#{testpath}"
    assert_match(/\d+\s+\d+\s+\d+\s+.*ply/, shell_output("wc #{testpath}/*.ply").strip)
  end
end
