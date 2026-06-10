class Dagim < Formula
  desc "Terminal editor for small, single-file DAGs"
  homepage "https://github.com/tunesmith/dagim"
  url "https://github.com/tunesmith/dagim/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "3e02fbc4a98df9fdb7341c25ac3bfb98892f44b167ad60d8f703e96fc0987e80"
  license "GPL-3.0-or-later"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(
      ldflags: "-s -w -X main.version=v#{version}",
    ), "./cmd/dagim"
  end

  test do
    assert_match "dagim v#{version}", shell_output("#{bin}/dagim --version")

    (testpath/"example.dagim").write <<~EOS
      # dagim v1

      node first: First
    EOS

    assert_match "OK", shell_output("#{bin}/dagim --check example.dagim")
  end
end
