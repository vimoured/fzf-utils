" Key legends for fzf that fit the list instead of being cut off.
"
" fzf never wraps --header, and beside a preview the header only gets the
" list's columns. With fzf-legend on $PATH (from the dotfiles' shell/bin),
" the legend is packed into as many rows as the list's width needs: at the
" start, on resize, and on the keys that toggle the preview. Without it, the
" legend is a plain --header, as before.
"
" The legend is one string with its items split by |, ╱ or │:
"
"   let l:opts = fzf#vim#with_preview({'options': [...]}, 'right,50%', 'ctrl-p')
"   call extend(l:opts.options,
"         \ fzf_utils#legend#options('C-r (regex) | C-f (fixed)', ['ctrl-p']))
"
" Add these options after fzf#vim#with_preview: the toggle keys given here
" are bound again, to toggle the preview and refit the legend.

function! fzf_utils#legend#options(legend, ...) abort
  let l:toggle_keys = get(a:, 1, [])
  if !executable('fzf-legend')
    return ['--header', a:legend]
  endif
  let l:refit = 'transform:fzf-legend --action ' . shellescape(a:legend)
  " load as well as start: fzf.vim's grep2 binds start to its first search
  let l:options = ['--bind', 'start,load,resize:' . l:refit]
  for l:key in l:toggle_keys
    call extend(l:options, ['--bind', l:key . ':toggle-preview+' . l:refit])
  endfor
  return l:options
endfunction
