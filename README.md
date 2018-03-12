Tagetik
=======

Repository flussi tagetik

-   Creo repository su github

-   Posizionarsi nella directory in cui voglio clonare il repository e lancio il
    comando

    git clone https://github.com/fzucaro/tagetik.git

-   In locale creo e carico i file del progetto

    -   Salvataggio delle modifiche

        -   Directory lavoro

            -   Index

            -   HEAD

        -   Salvare modifiche in Index: git add nomefile

        -   Salvare modifiche in HEAD (locale): git commit -m “Messaggio”

        -   Salvare modifiche in repository remoto: git push origin master
            (master o branch sul remoto)

         

Creazione Branch
================

-   Creo branch per release flusso movimenti: git checkout -b tgtk_mov01

###  

Conoscere current branch: git branch

 

Conflitti
=========

-   Comandi per risolvere i conflitti

    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    git add . or git add "your_file"
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    git commit -m "Merge conflicts resolved"
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
