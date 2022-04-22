# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Cwipc < Formula
  desc "xxxjack description goes here"
  homepage "https://github.com/cwi-dis/cwipc"
  license "MIT"
  url "https://github.com/cwi-dis/cwipc.git",
    tag: "exp-jack-homebrew-0.1",
    revision: "d2abbba64f2bd4ef1002869427bd0567932dd20a"
  version "exp-jack-homebrew-0.1"

  depends_on "cmake" => :build
  depends_on "git-lfs" => :build
  depends_on "pcl"
  depends_on "python3"
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
