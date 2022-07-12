# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Cwipc < Formula
  desc "xxxjack description goes here"
  homepage "https://github.com/cwi-dis/cwipc"
  license "MIT"
  url "https://github.com/cwi-dis/cwipc.git",
    tag: "exp-jack-build",
    revision: "f1a36e4d01154c7619f330c8d23a8287a8c67dc7"
  version "exp-jack-build"

  depends_on "cmake" => :build
  depends_on "git-lfs" => :build
  depends_on "pcl"
  depends_on "python@3.9"
  depends_on "jpeg-turbo"
  depends_on "librealsense" => :recommended

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    system "#{bin}/cwipc_generate", "1", "#{testpath}"
    assert_match(/\d+\s+\d+\s+\d+\s+.*ply/, shell_output("wc #{testpath}/*.ply").strip)
  end
end
