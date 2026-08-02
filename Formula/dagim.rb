class Dagim < Formula
  desc "Terminal editor for small, single-file DAGs"
  homepage "https://github.com/tunesmith/dagim"
  url "https://github.com/tunesmith/dagim/archive/refs/tags/v1.2.0.tar.gz"
  sha256 "430d7f3b43b5a5258b60c68e699f6d41d0e37d192245ddf9b381437ea2f193cd"
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
