# Machine name.
function box_name {
    [ -f ~/.box-name ] && cat ~/.box-name || echo $HOST
}

# Directory info.
local current_dir='${PWD/#$HOME/~}'

# VCS
YS_VCS_PROMPT_PREFIX1="${FG[189]}on${FX[reset]} "
YS_VCS_PROMPT_PREFIX2=":${FG[110]}"
YS_VCS_PROMPT_SUFFIX="${FX[reset]} "
YS_VCS_PROMPT_DIRTY=" ${FG[167]}✗"
YS_VCS_PROMPT_CLEAN=" ${FG[149]}✔︎"

# Git info.
local git_info='$(git_prompt_info)'
local git_last_commit='$(git log --pretty=format:"%h \"%s\"" -1 2> /dev/null)'
ZSH_THEME_GIT_PROMPT_PREFIX="${YS_VCS_PROMPT_PREFIX1}git${YS_VCS_PROMPT_PREFIX2}"
ZSH_THEME_GIT_PROMPT_SUFFIX="$YS_VCS_PROMPT_SUFFIX"
ZSH_THEME_GIT_PROMPT_DIRTY="$YS_VCS_PROMPT_DIRTY"
ZSH_THEME_GIT_PROMPT_CLEAN="$YS_VCS_PROMPT_CLEAN"

# HG info
local hg_info='$(ys_hg_prompt_info)'
ys_hg_prompt_info() {
    if [ -d '.hg' ]; then
        echo -n "${YS_VCS_PROMPT_PREFIX1}hg${YS_VCS_PROMPT_PREFIX2}"
        echo -n $(hg branch 2>/dev/null)
        if [ -n "$(hg status 2>/dev/null)" ]; then
            echo -n "$YS_VCS_PROMPT_DIRTY"
        else
            echo -n "$YS_VCS_PROMPT_CLEAN"
        fi
        echo -n "$YS_VCS_PROMPT_SUFFIX"
    fi
}

# Prompt format: \n # TIME USER at MACHINE in [DIRECTORY] on git:BRANCH STATE \n $
PROMPT="
${FG[110]}%n \
${FG[217]}at \
${FG[149]}$(box_name) \
${FG[217]}in \
${FX[bold]}${FG[180]}[${current_dir}]${FX[reset]} \
${hg_info} \
${git_info} \
${git_last_commit}
${FG[176]}%* \
${FX[bold]}${FG[189]}› ${FX[reset]}"

if [[ "$USER" == "root" ]]; then
PROMPT="
${FG[167]}%* \
${FX[bold]}${FG[110]}#${FX[reset]} \
${BG[180]}${FG[110]}%n${FX[reset]} \
${FG[217]}at \
${FG[149]}$(box_name) \
${FG[217]}in \
${FX[bold]}${FG[180]}[${current_dir}]${FX[reset]}\
${hg_info}\
${git_info}
${FX[bold]}${FG[167]}$ ${FX[reset]}"
fi
