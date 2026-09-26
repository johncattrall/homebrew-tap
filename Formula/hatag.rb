class Hatag < Formula
  desc "Tag export, conversion, and diagnostics for Home Assistant"
  homepage "https://github.com/johncattrall/hatag"
  url "https://github.com/johncattrall/hatag/releases/download/v0.1.2/hatag-0.1.2-arm64-macos.tar.gz"
  sha256 "9d4cf4329fb0b5521eff0da18e631d8a521d8bff5221d74d070627716794de91"
  version "0.1.2"

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
    system libexec/"venv/bin/python", "-c",
           "from findmy import FindMyAccessory; import sys; a = FindMyAccessory.from_json(sys.argv[1]); assert a.to_json()['alignment_index'] == 96; assert a.master_key == bytes([1])*28",
           outputs.first
    refute_path_exists testpath/"keystore.plist"
    output = shell_output("#{bin}/hatag --diagnose #{testpath}/missing.json 2>&1", 1)
    assert_match "cannot read input", output
    refute_match "Install requirements-diagnostics", output
  end
end
