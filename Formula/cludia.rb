class Cludia < Formula
  desc "Local, file-first workbench for explicit arguments"
  homepage "https://github.com/tunesmith/cludia"
  url "https://github.com/tunesmith/cludia/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "bcb387b85284a9ef4d1392d6c4a785cd30b83d2f294c3a5d623a9c3006a85350"
  license "GPL-3.0-or-later"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(
      ldflags: "-s -w -X main.version=v#{version}",
    ), "./cmd/cludia"
  end

  test do
    assert_match "cludia v#{version}", shell_output("#{bin}/cludia --version")

    system bin/"cludia", "init", "case.arg",
           "--title", "Formula Test", "--text", "First premise."
    system bin/"cludia", "add", "case.arg", "--text", "Second premise."

    validation = shell_output("#{bin}/cludia validate --json case.arg")
    assert_match '"schema_version": 2', validation
    assert_match '"profile": "cludia"', validation
    assert_match '"ok": true', validation

    system bin/"cludia", "derive", "case.arg",
           "--source", "P1", "--source", "P2",
           "--target-text", "Both premises support this finding."

    evaluation = shell_output("#{bin}/cludia evaluate --json case.arg")
    assert_match '"schema_version": 1', evaluation
    assert_match '"mode": "grounded"', evaluation
    assert_match '"id": "L1"', evaluation
    assert_match '"effective_truth": "T"', evaluation
  end
end
