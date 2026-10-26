class Dagim < Formula
  desc "Terminal editor for small, single-file DAGs"
  homepage "https://github.com/tunesmith/dagim"
  url "https://github.com/tunesmith/dagim/archive/refs/tags/v1.6.0.tar.gz"
  sha256 "8a18b54b324e9e6a26a140ce50ebb580359a162c7bd3ce8e5dcbd16d0b92bb2a"
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
    assert_match '"schema_version": 2', ready
    assert_match '"ok": true', ready
    assert_match '"id": "first"', ready

    system bin/"dagim", "complete", "example.dagim", "first"
    assert_match '"complete": true', shell_output("#{bin}/dagim show example.dagim first --json")

    assert_match '"id": "preserve_stable_ids"', shell_output("#{bin}/dagim guidance --json")

    (testpath/"other").write "node first: Another independent task\n"
    system bin/"dagim", "collection", "create", "daily"
    system bin/"dagim", "collection", "add", "daily", "example.dagim", "--as", "example"
    system bin/"dagim", "collection", "add", "daily", "other", "--as", "other"
    assert_match '"ref": "other:first"', shell_output("#{bin}/dagim ready daily --json")
    system bin/"dagim", "complete", "daily", "other:first"
    assert_match '"complete": true', shell_output("#{bin}/dagim show other first --json")
  end
end
