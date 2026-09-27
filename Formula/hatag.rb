class Hatag < Formula
  desc "Tag export, conversion, and diagnostics for Home Assistant"
  homepage "https://github.com/johncattrall/hatag"
  url "https://github.com/johncattrall/hatag/releases/download/v0.1.5/hatag-0.1.5-arm64-macos.tar.gz"
  sha256 "5bbd57b1e946e8e123f562a1bff47fd379527a194c13bf8a656955fb1d51b680"
  version "0.1.5"

  depends_on arch: :arm64
  depends_on macos: :sonoma
  depends_on "python@3.14"

  def install
    libexec.install "bin/hatag"
    python = Formula["python@3.14"].opt_bin/"python3.14"
    system python, "-m", "venv", libexec/"venv"
    system libexec/"venv/bin/python", "-m", "pip", "install",
           "--no-index", "--only-binary=:all:", "--require-hashes",
           "--find-links=#{buildpath}/wheels", "-r", "requirements.lock"
    system libexec/"venv/bin/python", "-m", "pip", "check"
    (bin/"hatag").write <<~SH
      #!/bin/sh
      export HATAG_PYTHON="${HATAG_PYTHON:-#{libexec}/venv/bin/python}"
      exec "#{libexec}/hatag" "$@"
    SH
    (bin/"hatag").chmod 0755
    pkgshare.install "requirements.lock", "wheel-manifest.json", "licenses"
  end

  def caveats
    <<~EOS
      Bluetooth diagnostics use the bundled Python environment automatically.
      Enable Bluetooth and grant your terminal Bluetooth access when macOS asks.
      Diagnostics are read-only unless --save-alignment is supplied.
      Exported files and backups contain private tracking keys; keep them private.
      This binary package is for Apple Silicon macOS 14 or newer.
      Exports default to the current directory; override with --output-dir.
      Authentication state stays under ~/Library/Application Support/hatag/state.
      If output is not writable, change directories; do not run hatag with sudo.
    EOS
  end

  test do
    require "json"
    fixture = {
      type: "accessory",
      master_key: "01" * 28,
      skn: "02" * 32,
      sks: "03" * 32,
      paired_at: "2025-01-01T00:00:00+00:00",
      name: "Brew test",
      model: "AirTag",
      identifier: "synthetic-brew-test",
      alignment_date: "2025-01-02T00:00:00+00:00",
      alignment_index: 96,
    }
    (testpath/"input.json").write JSON.generate(fixture)
    system bin/"hatag", "--convert=home-assistant",
           "--output-dir", testpath/"converted", testpath/"input.json"
    outputs = (testpath/"converted").glob("*.findmy.json")
    assert_equal 1, outputs.length
    assert_equal JSON.parse(JSON.generate(fixture)), JSON.parse(outputs.first.read)
    (testpath/"default-output").mkpath
    (testpath/"default-output").chmod 0755
    cd testpath/"default-output" do
      system bin/"hatag", "--convert=home-assistant", testpath/"input.json"
      assert_equal 1, Dir["*.findmy.json"].length
    end
    assert_equal 0755, (testpath/"default-output").stat.mode & 0777
    system libexec/"venv/bin/python", "-c",
           "from findmy import FindMyAccessory; import sys; a = FindMyAccessory.from_json(sys.argv[1]); assert a.to_json()['alignment_index'] == 96; assert a.master_key == bytes([1])*28",
           outputs.first
    refute_path_exists testpath/"keystore.plist"
    output = shell_output("#{bin}/hatag --diagnose #{testpath}/missing.json 2>&1", 1)
    assert_match "cannot read input", output
    refute_match "Install requirements-diagnostics", output
  end
end
