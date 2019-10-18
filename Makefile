ZDOTDIR := $(if $(ZDOTDIR),$(ZDOTDIR),$(HOME))

all: update

update: update_prezto
	# chezmoi apply

update_prezto:
	cd $(ZDOTDIR)/.zprezto
	git pull
	git submodule update --init --recursive

install_prezto:
	git clone --recursive https://github.com/sorin-ionescu/prezto.git $(ZDOTDIR)/.zprezto

install_yay:
	git clone https://aur.archlinux.org/yay.git /tmp/yay
	cd /tmp/yay
	makepkg -rsci --noconfirm

install_prezto_fzf:
	mkdir $(ZDOTDIR)/.zprezto-contrib
	git clone --recursive https://gitlab.com/saruman9/fzf-prezto.git $(ZDOTDIR)/.zprezto-contrib/fzf
