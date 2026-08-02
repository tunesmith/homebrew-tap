class Dagim < Formula
  desc "Terminal editor for small, single-file DAGs"
  homepage "https://github.com/tunesmith/dagim"
  url "https://github.com/tunesmith/dagim/archive/refs/tags/v1.3.1.tar.gz"
  sha256 "92726b03c470e8749a63f68b809a4815c6ed81781729cbfb50e0151755c6dfc8"
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

    ready = shell_output("#{bin}/dagim ready example.dagim --json")
    assert_match '"schema_version": 1', ready
    assert_match '"id": "first"', ready

    system bin/"dagim", "complete", "example.dagim", "first"
    assert_match '"complete": true', shell_output("#{bin}/dagim show example.dagim first --json")
  end
end
