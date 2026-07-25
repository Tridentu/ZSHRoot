# Smart command not found 
## **Why**

I wrote this plug in out of frustration from how the [command-not-found](https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/command-not-found/command-not-found.plugin.zsh)  plugin provided by OMZ only displays Homebrew available packages

## **What does it do**

I wanted a plugin that shows me all the available options when a command is not found, so I included many package manager to check from so the plugin can work on multiple systems

> [!NOTE]
> If you didn't find the packager manager you are looking for please inform me or add it yourself and submit a pull request

## **How to get it**

1.  make sure [_Oh My Zh_](https://ohmyz.sh/) and  [fzf](https://junegunn.github.io/fzf/installation/) are installed
2.  clone the repository
    
    ```sh
    git clone https://github.com/rami-shalhoub/Smart-command-not-found.git ~/.oh-my-zsh/custom/plugins/
    ```
3.  add “smart-command-not-found” to the plugins array in `~/.zshrc`
    
    ```plain
    plugins=(... smart-command-not-found ...)
    ```
4. (Optional) specify the managers that you want the plugin to use, in `~/.zshrc` add
   ```plain
   export MANAGERS=('apt' 'flatpak' 'homebrew')
   ```

## **Supported Package Managers**
- `apt` ( and _nala_ if exist)
- `dnf`
- `pacman`
- _**aur**_:
  - `yay`*
  - `paru`*
  - `aura`*
- `zypper`*
- `homebrew`
- `flatpak`
- `snap`*
- `nix`*

> [!CAUTION]
> The _**aur**_ managers `yay` `paru` `aura` have an issue\
> Please do not use them as they will not display any results

> [!IMPORTANT]
> The managers marked with **\*** are not (well) tested yet\
> you can help improving the plugin by providing feedback if you are able to test them 

## **How it looks**

<figure class="table" style="width:100%;">
	<table class="ck-table-resized" style="border-style:none;">
		<colgroup>
			<col style="width:55.21%;">
			<col style="width:44.79%;">
		</colgroup>
		<tbody>
			<tr>
				<td style="border-style:none;">
					<p>
						&nbsp;
					</p>
					<figure class="image image-style-block-align-left">
						<img style="aspect-ratio:854/413;" src="./pictures/Smart command not found_Sc.png" width="854" height="413">
					</figure>
				</td>
				<td style="border-style:none;">
					<figure class="image image_resized" style="width:96.37%;">
						<img style="aspect-ratio:1056/1037;" src="./pictures/1_Smart command not found_Sc.png" width="1056" height="1037">
					</figure>
				</td>
			</tr>
		</tbody>
	</table>
</figure>
<p>
	&nbsp;
</p>
