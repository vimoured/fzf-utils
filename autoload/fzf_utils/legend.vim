" Key legends for fzf that fit the list instead of being cut off.
"
" fzf never wraps --header or --footer, and beside a preview they only get the
" list's columns. With fzf-legend on $PATH (from the dotfiles' shell/bin),
" the legend is packed into as many rows as the list's width needs: at the
" start, on resize, and on the keys that toggle the preview. Without it, the
" legend is a plain --header. Either way it takes the place of fzf.vim's key
" footer (--no-footer), which would be cut off the same way.
"
" The legend is one string with its items split by |, ╱ or │:
"
"   let l:opts = fzf#vim#with_preview({'options': [...]}, 'right,50%', 'ctrl-p')
"   call extend(l:opts.options,
"         \ fzf_utils#legend#options('C-r (regex) | C-f (fixed)', ['ctrl-p']))
"
" Add these options after fzf#vim#with_preview: the toggle keys given here
" are bound again, to toggle the preview and refit the legend. The legend is
" added to what the command does at the start (start:+), so a command that
" binds start keeps it.

function! fzf_utils#legend#options(legend, ...) abort
  let l:toggle_keys = get(a:, 1, [])
  if !executable('fzf-legend')
    return ['--no-footer', '--header', a:legend]
  endif
  let l:refit = 'transform:fzf-legend --action ' . shellescape(a:legend)
  " load as well: fzf.vim's grep2 binds start after these options, which
  " replaces them there
  let l:options = ['--no-footer', '--bind', 'start,load,resize:+' . l:refit]
  for l:key in l:toggle_keys
    call extend(l:options, ['--bind', l:key . ':toggle-preview+' . l:refit])
  endfor
  return l:options
endfunction

" The keys fzf.vim's footer lists for a command of its own, besides Show,
" Enter and the default actions, by the command's name in g:fzf_vim
let s:own_keys = {
      \ 'buffers': 'C-A-x (unload)',
      \ 'commits': 'C-s (toggle sort) | C-y (yank hashes)',
      \ 'rg': 'A-a (all) | A-d (none)',
      \ }

" fzf_utils#legend#options() for one of fzf.vim's commands, by its name in
" g:fzf_vim ('gfiles-diff' for :GFiles?, 'buffers', 'files', 'rg',
" 'commits'): the keys its footer lists, after the caller's own (a:1, a
" legend), then the keys that toggle the preview (a:2, by default
" g:fzf_vim.preview_window's: ctrl-/):
"
"   let g:fzf_vim['gfiles-diff_options'] = fzf_utils#legend#fzf_vim('gfiles-diff')
function! fzf_utils#legend#fzf_vim(name, ...) abort
  let l:toggle_keys = get(a:, 2, s:conf('preview_window', ['', 'ctrl-/'])[1:])
  let l:show_key = s:conf('show_key', 'ctrl-o')
  let l:legend = [get(a:, 1, ''),
        \ empty(l:show_key) ? '' : s:label(l:show_key) . ' (show)',
        \ get(s:own_keys, a:name, ''),
        \ 'Enter (open) | C-x (hsplit) | C-v (vsplit) | C-t (tab)']
        \ + map(copy(l:toggle_keys), 's:label(v:val) . " (toggle preview)"')
  return fzf_utils#legend#options(join(filter(l:legend, '!empty(v:val)'), ' | '), l:toggle_keys)
endfunction

" A setting of fzf.vim's, where fzf.vim looks for it
function! s:conf(name, default) abort
  return get(get(g:, 'fzf_vim', {}), a:name, get(g:, 'fzf_' . a:name, a:default))
endfunction

" 'ctrl-/' -> 'C-/', 'alt-a' -> 'A-a'
function! s:label(key) abort
  return substitute(substitute(a:key, '\<ctrl-', 'C-', 'g'), '\<alt-', 'A-', 'g')
endfunction
