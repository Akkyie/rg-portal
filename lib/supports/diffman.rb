class Diffman
  def initialize
    @tempfiles = []
  end

  def diff(string1, string2)
    files = [tempfile(string1), tempfile(string2)]
    params = files.map(&:path)
    Open3.popen3(diff_bin, *params) { |i, o, e, w| o.read }
  ensure
    remove_tempfiles!
  end

  def patch(string, patch, reverse: false)
    files = [tempfile(string), tempfile(patch)]
    params = files.map(&:path)
    params << '-R' if reverse
    return nil if Open3.popen3(patch_bin, *params) { |i, o, e, w | w.value } != 0
    files.first.open
    str = files.first.read
    files.first.close
    str
  ensure
    remove_tempfiles!
  end

  private

  def diff_bin
    diffs = ['diff', 'ldiff']
    diffs.find { |name| system('which', '-s', name) }
  end

  def patch_bin
    patches = ['patch']
    patches.find { |name| system('which', '-s', name) }
  end

  def tempfile(string)
    Tempfile.new('diffman').tap do |file|
      @tempfiles.push(file)
      file.print(string)
      file.flush
      file.close
    end
  end

  def remove_tempfiles!
    @tempfiles.each do |file|
      file.unlink if file.path && File.exist?(file.path)
    end
  end
end
