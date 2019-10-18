ZDOTDIR := $(if $(ZDOTDIR),$(ZDOTDIR),$(HOME))
PACKAGES_DIR := $(HOME)/.local/share/packages
PREZTO := $(ZDOTDIR)/.zprezto
FZF := $(ZDOTDIR)/.zprezto-contrib/fzf
YAY := $(shell which yay)
YAY_COMMAND := yay -Sy --needed --norebuild --noconfirm \
	$$(cat $(PACKAGES_DIR)/base.list | sed 's/ \#.*$$//g')


.PHONY: all
all: update

update: update_prezto update_chezmoi

update_chezmoi:
	chezmoi apply

update_prezto:
	cd $(ZDOTDIR)/.zprezto && \
	git pull && \
	git submodule update --init --recursive

install: $(PREZTO) $(FZF) $(YAY) install_packages

$(PREZTO) install_prezto:
	git clone --recursive \
		https://github.com/sorin-ionescu/prezto.git $(ZDOTDIR)/.zprezto

$(YAY) install_yay:
	git clone https://aur.archlinux.org/yay.git /tmp/yay
	cd /tmp/yay && \
	makepkg -rsci --noconfirm

$(FZF) install_fzf:
	mkdir $(ZDOTDIR)/.zprezto-contrib
	git clone --recursive \
		https://gitlab.com/saruman9/fzf-prezto.git $(ZDOTDIR)/.zprezto-contrib/fzf

install_packages: $(YAY) update_chezmoi install_packages_base \
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
