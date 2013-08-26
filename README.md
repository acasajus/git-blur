git-blur
========

git-blur transparently encrypts and decrypts files in a git repository. It is heavily based on [git-crypt](https://github.com/AGWA/git-crypt "git-crypt"). You can choose which files to encrypt. Each file will be encrypted individually. This way there can be private and public files in the same repository. People withouth git-blur or without the proper key will still be able to access the public files.  

Key files can be generated randomly or using a password. If you generate the key file randomly you need to *BACKUP* it in a secure place. If the key file is lost, encrypted files won't be able to be decrypted. On the other hand, if you generate the key file using a password, you will always be able to generate the same key using the same password.

git-blur was written by Adria Casajus <adriancasajus at gmail dot com>


Installing git-blur
====================

git-blur is packed as a gem. Just run:

    $ gem install git-blur 

and it should do the trick.

Using git-blur
===============

First you need to generate a key file

    $ git blur init

It will ask for your password twice to generate your key file. From then just create a .gitattributes file specifying which files to encrypt:

    $ cat .gitattributes
    secretfile filter=git-blur diff=git-blur
    *.key filter=git-crypt diff=git-crypt

The .gitattributes file should be committed into the repository but make sure you *DON'T ENCRYPT* the .gitattributes file. 

To retrieve a repo with already encrypted files just:
 
    $ git clone /path/to/repo
    $ cd repo
    $ git blur init

After generating the keyfile git should unencrypt automatically all encrypted files.

Security
=========

git-blur encrypts files using three nested ciphers using an IV derived from the file hash.  Each file is first encrypted with AES-256 then with Blowfish and then DES3. All ciphers are used in CBC mode. I've chosen this ciphers because they are the ones included in OpenSSL.  

Key file is stored unencrypted on disk under .git/blur.conf. The user is responsible for protecting it and ensuring it's safely distributed only to authorized people. 


Warrant
========

Software is provided as-is. It was intended as an experiment with ruby and ended up being the way I crypt data in my repos. If you've got
any suggestion/improvement please create an issue and I'll look into it. 
