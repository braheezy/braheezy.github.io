---
categories:
- Guides
date: "2022-07-31T21:47:19Z"
tags:
- Ansible
title: Automating Firefox with Ansible
---
During my work on a [Catppuccin-ified image](https://github.com/braheezy/prettybox-catppuccin), I wrote an Ansible playbook to automate the installation and configuration of Firefox. The playbook is used to build an image from a known state, so it's not 100% idempotent. But it was still just enough research that it warranted sharing.

## Installation
Installing is easy. It's so trivial, I shouldn't even show it:

```yaml
- name: Ensure firefox is installed
  become: yes
  yum:
    name: firefox
    state: present
```

Best. Ansible. Dev. Ever.

## Configuration
I'm installing Firefox so that I can ultimately apply a Catppuccin theme to it. These themes are [available as addons](https://addons.mozilla.org/en-US/firefox/addon/catppuccin-mocha-mauve/) from the Firefox store. Super easy to install if you're sitting at the web browser. But we won't be.

### Research
I don't know anything useful about Firefox addons or how themes work. I open a bunch of browser tabs and figure out the following:
- The [Catppuccin assets](https://github.com/catppuccin/firefox) appear to be JSON manifest files describing which UI elements to apply which hex codes to.
- The `firefox` command on Linux has a [bunch of useful command line options](https://wiki.mozilla.org/Firefox/CommandLineOptions).
- When you install Firefox, the useful stuff lives in `~/.mozilla/firefox`.
- Firefox has profiles that can be [controlled by a config file](http://kb.mozillazine.org/Profiles.ini_file).

This is enough information to start automating some stuff.

### Approach
At a high-level, the following must be done:
1. Create Firefox profile
2. Download/install/marry theme to profile
3. Ensure profile is used when Firefox is run

Some playbook snippets for creating a Firefox profile:
```yaml
# Use the Firefox CLI to create a new profile.
- name: Create new Firefox profile
  environment:
    # Seems to expect a graphical session, so trick it into thinking there is one with $DISPLAY env var.
    DISPLAY: :0
  command: firefox -no-remote -CreateProfile {{ profile_name }}

# Get a reference to the profile config location on disk.
# The command above created a folder in the firefox config directory named <random string>.<profile name>/. We need to find it.
- name: Find profile directory
  find:
    paths: '{{ ansible_env.HOME }}/.mozilla/firefox'
    patterns: '*.{{ profile_name }}'
    file_type: directory
  register: profile_dir

# Pull the thing we care about out: the path to the profile directory.
- name: Parse result for profile path
  set_fact:
    profile_path: "{{ profile_dir.files[0].path }}"
```

To apply the theme, I'd like to download the theme file to disk and put it in the same spot(s) it would go if installed through the browser. To get the download link, I try going directly to the addon store and seeing what link the "Install Theme" button gives me.

![Firefox Install Theme button link](/assets/img/Firefox_addon.png)

Cool, it's an `.xpi` file[^1]. But that `3954898` in the URL smells like a randomly generated build number that's probably going to change often. I don't want to update this playbook every time that happens. Can I ask Firefox for the information?

Yes! Enter into the arena: [Mozilla Addons API](https://addons-server.readthedocs.io/en/latest/index.html). After much noodling through API docs and doing some light testing with Postman, the [Detail endpoint](https://addons-server.readthedocs.io/en/latest/topics/api/addons.html#detail) seems to meet my needs and I arrive at something useful:
```yaml
# theme_name: exact name of theme to get details on e.g. catppuccin-mocha-mauve
- name: Call Firefox Addons API for theme info
  uri:
    url: https://addons.mozilla.org/api/v5/addons/addon/{{ theme_name }}
    return_content: yes
  register: api_call

# Get the bits of info we need: the current download link for the addon and it's unique identifier
- name: Parse result for download link
  set_fact:
    theme_download_link: "{{ api_call.json.current_version.file.url }}"
# The actual extension on disk gets renamed to <guid>.xpi when installed.
- name: Parse result for guid
  set_fact:
    theme_guid: "{{ api_call.json.guid }}"
```

It's about time to actually download the extension, making sure we put it in the right location:
```yaml
- name: Ensure extensions directory exists
  file:
    path: '{{ profile_path }}/extensions'
    state: directory
    mode: 0755

- name: Download theme extension file
  get_url:
    url: "{{ theme_download_link }}"
    dest: '{{ profile_path }}/extensions/{{ theme_guid }}.xpi'
    mode: 0644
```

Feeling confident, I start testing. Odd dialogs from Firefox appear, speaking of default profiles, last used profiles, and ultimately the theme isn't applied when I get to the browser. Hmm...

The problem is that while I've created a profile and installed a theme, I didn't introduce them to each other and tell Firefox about it. Creating the correct [profiles.ini](http://kb.mozillazine.org/Profiles.ini_file) file should solve this. After reading docs and comparing various working and broken configs, I land on this:
```yaml
- name: 'Set [General] options in profiles.ini'
  ini_file:
    path: '{{ config_dir }}/profiles.ini'
    section: General
    option: '{{ item.option }}'
    value: '{{ item.value }}'
    mode: 0644
    create: yes
    no_extra_spaces: yes
  loop:
    # Suppress the dialog that asks for which profile to use.
    - { option: StartWithLastProfile, value: 1 }
    # Needs to be here, probably spec version of ini file.
    - { option: Version, value: 2 }
  loop_control:
    label: "{{ item.option }}"

- name: Define custom profile and set as default
  ini_file:
    path: '{{ config_dir }}/profiles.ini'
    section: Profile0
    option: '{{ item.option }}'
    value: '{{ item.value }}'
    no_extra_spaces: yes
  loop:
    # All the required settings to enable/set the profile.
    # Mozilla docs good!
    - { option: Name, value: '{{ profile_name }}' }
    - { option: IsRelative, value: 1 }
    - { option: Path, value: '{{ profile_path | basename }}' }
    - { option: Default, value: 1 }
    - { option: Locked, value: 1 }
  loop_control:
    label: "{{ item.option }}"
```
One more full test and success! Firefox launches like normal but now has a theme applied.

## Full Role
The whole thing all at once:
```yaml
# defaults/main.yml
---
# Name of Firefox profile that will be created
profile_name: catppuccin

# Config location for Firefox
config_dir: '{{ ansible_env.HOME }}/.mozilla/firefox'

# The specific Catppuccin theme to use
theme_name: catppuccin-mocha-mauve

# tasks/main.yml
---

- name: Ensure firefox is installed
  become: yes
  yum:
    name: firefox
    state: present

- name: Create new Firefox profile
  environment:
    DISPLAY: :0
  command: firefox -no-remote -CreateProfile {{ profile_name }}

- name: Find profile directory
  find:
    paths: '{{ config_dir }}'
    patterns: '*.{{ profile_name }}'
    file_type: directory
  register: profile_dir

- name: Parse result for profile path
  set_fact:
    profile_path: "{{ profile_dir.files[0].path }}"

- name: Call Firefox Addons API for theme info
  uri:
    url: https://addons.mozilla.org/api/v5/addons/addon/{{ theme_name }}
    return_content: yes
  register: api_call

- name: Parse result for download link
  set_fact:
    theme_download_link: "{{ api_call.json.current_version.file.url }}"

- name: Parse result for guid
  set_fact:
    theme_guid: "{{ api_call.json.guid }}"

- name: Ensure extensions directory exists
  file:
    path: '{{ profile_path }}/extensions'
    state: directory
    mode: 0755

- name: Download theme extension file
  get_url:
    url: "{{ theme_download_link }}"
    dest: '{{ profile_path }}/extensions/{{ theme_guid }}.xpi'
    mode: 0644

# http://kb.mozillazine.org/Profiles.ini_file
- name: Set general options in profiles.ini
  ini_file:
    path: '{{ config_dir }}/profiles.ini'
    section: General
    option: '{{ item.option }}'
    value: '{{ item.value }}'
    mode: 0644
    create: yes
    no_extra_spaces: yes
  loop:
    - { option: StartWithLastProfile, value: 1 }
    - { option: Version, value: 2 }
  loop_control:
    label: "{{ item.option }}"

- name: Define custom profile and set as default
  ini_file:
    path: '{{ config_dir }}/profiles.ini'
    section: Profile0
    option: '{{ item.option }}'
    value: '{{ item.value }}'
    no_extra_spaces: yes
  loop:
    - { option: Name, value: '{{ profile_name }}' }
    - { option: IsRelative, value: 1 }
    - { option: Path, value: '{{ profile_path | basename }}' }
    - { option: Default, value: 1 }
    - { option: Locked, value: 1 }
  loop_control:
    label: "{{ item.option }}"
```

[^1]:  This still amazes me. Turns out, most random file extensions you might find are probably some type of archive file. Big Zip doesn't want you to know this.

    Here, a quick `unzip *.xpi` shows inside: A `META/` folder containing metadata files and the manifest JSON theme file noted earlier.