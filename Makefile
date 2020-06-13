# Don't use `rm` program

ZDOTDIR := $(if $(ZDOTDIR),$(ZDOTDIR),$(HOME))
PACKAGES_DIR := $(HOME)/.local/share/packages

PREZTO := $(ZDOTDIR)/.zprezto
FZF := $(ZDOTDIR)/.zprezto-contrib/fzf
TPM := $(HOME)/.tmux/plugins/tpm
YAY := /bin/yay
SPACEMACS := $(HOME)/.emacs.d

YAY_COMMAND := yay -Sy --needed --norebuild --noconfirm \
	$$(cat $(PACKAGES_DIR)/base.list \
	| sed 's/ \#.*$$//g' \
	| grep -vx "$$(yay -Qq)")


.PHONY: all update install
all: update

update: update_prezto update_fzf update_spacemacs update_dotfiles

update_dotfiles:
	chezmoi apply --verbose

update_prezto:
	cd $(ZDOTDIR)/.zprezto && \
	git pull && \
	git submodule update --init --recursive

update_fzf:
	cd $(ZDOTDIR)/.zprezto-contrib/fzf && \
	git pull && \
	git submodule update --init --recursive

update_spacemacs:
	cd $(SPACEMACS) && \
	git fetch && \
	git reset --hard origin/master

install: $(PREZTO) $(FZF) $(TPM) $(YAY) update_dotfiles install_packages \
	$(SPACEMACS)

$(PREZTO) install_prezto:
	git clone --recursive \
	https://github.com/sorin-ionescu/prezto.git $(ZDOTDIR)/.zprezto || true

$(YAY) install_yay:
	git clone https://aur.archlinux.org/yay.git /tmp/yay || true
	cd /tmp/yay && \
	makepkg -rsci --noconfirm

$(FZF) install_fzf:
	mkdir $(ZDOTDIR)/.zprezto-contrib
	git clone --recursive \
	https://github.com/saruman9/fzf-prezto.git $(ZDOTDIR)/.zprezto-contrib/fzf \
	|| true

$(TPM) install_tpm:
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm || true

install_packages: $(YAY) install_packages_base \
	install_packages_desktop install_packages_developing \
	install_packages_latex install_packages_mobile install_packages_re

install_packages_base:
	$(YAY_COMMAND)

install_packages_desktop:
	$(subst base.list,desktop.list,$(YAY_COMMAND))

install_packages_developing:
	$(subst base.list,developing.list,$(YAY_COMMAND))

install_packages_latex:
	$(subst base.list,latex.list,$(YAY_COMMAND))

install_packages_mobile:
	$(subst base.list,mobile.list,$(YAY_COMMAND))

install_packages_re:
	$(subst base.list,re.list,$(YAY_COMMAND))

$(SPACEMACS) install_spacemacs:
	git clone https://github.com/syl20bnr/spacemacs $(HOME)/.emacs.d
	cd $(SPACEMACS) && \
	git checkout develop
