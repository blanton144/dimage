spawn, 'pwd', cwd
words=strsplit(cwd[0], '/',/extr)
base=words[n_elements(words)-1]
images=base+'-'+['u', 'g', 'r', 'i', 'z']+'.fits.gz'
detect_multi, base, images, ref=2, single=188, /noclobber, /sgset, /hand
