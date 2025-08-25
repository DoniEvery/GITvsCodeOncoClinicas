import { LightningElement, wire, track } from 'lwc';
import getArtigosComQuestoesDTO from '@salesforce/apex/APP_CommunityFaqController.getArtigosComQuestoesDTO';
import searchIcon from '@salesforce/resourceUrl/App_searchIcon';
export default class AppFaqSidebar extends LightningElement {
    artigos;
    searchIcon = searchIcon;
    @wire(getArtigosComQuestoesDTO)
    wiredArtigos({ data, error }) {
        if (data) {
            this.artigos = data.map(artigo => {
                return {
                    ...artigo, tema: this.stripHtml(artigo.tema),
                    questoes: artigo.questoes.map(q => {
                        return {
                            ...q, titulo: this.stripHtml(q.titulo),
                            conteudo: this.stripHtmlAndPreserveLineBreaks(q.conteudo) // ele está aqui, dentro deum map que está dentro de outro map
                        };
                    })
                };
            });



            this.allArtigos = this.artigos

        } else if (error) { console.error(error); }
    }



    handleDigitName(event) {
        this.searchKey = event.target.value.toLowerCase();
        this.applyFilter();


    }

    stripHtml(htmlString) {
        if (!htmlString) return '';
        const parser = new DOMParser();
        const doc = parser.parseFromString(htmlString, 'text/html');
        return doc.body.textContent || '';
    }
    stripHtmlAndPreserveLineBreaks(htmlString) {
        if (!htmlString) {
            return '';
        }

        // console.log('HTML de entrada:', htmlString);

        const parser = new DOMParser();
        const doc = parser.parseFromString(htmlString, 'text/html');
        const paragraphs = doc.querySelectorAll('p');
        const result = Array.from(paragraphs)
            .map(p => p.textContent || '')
            .join('\n');

        // console.log('Texto de saída:', result);

        return result;
    }
    openArticle(event) {
        const id = event.currentTarget.dataset.id;
        this.artigos = this.artigos.map(art => {
            if (art.id === id) {
                return {
                    ...art,
                    isOpen: !art.isOpen
                };
            }
            return art;
        });

    }
    openItem(event) {
        event.stopPropagation();
        const artid = event.currentTarget.dataset.artid;
        const qid = event.currentTarget.dataset.qid;
        console.log(
            artid,
            qid);

        this.artigos = this.artigos.map(art => {
            if (art.id === artid) {

                return {
                    ...art,
                    questoes: art.questoes.map(q => {
                        console.log(0);
                        if (q.id === qid) {
                            console.log(1);

                            // const isHighlighted = q.isHighlighted || false;
                            return {
                                ...q,
                                isHighlighted: !q.isHighlighted
                                // questionClass: isHighlighted ? 'questionClass open' : 'questionClass'
                            };


                        }
                        return q;


                    })

                };
            }
            return art;
        });

    }

    applyFilter() {
        let filtered = [...this.allArtigos];

        if (this.searchKey && this.searchKey.trim().length >= 3) {
            const search = this.searchKey.trim().toLowerCase();

            filtered = filtered.map(art => {
                const articleMatches = art.tema && art.tema.toLowerCase().includes(search);

                // retorna o artigo completo sem filtrar as questões
                if (articleMatches) {
                    return {
                        ...art,
                        questoes: art.questoes
                    };
                }
                return null;
            }).filter(art => art !== null);
        }

        this.artigos = filtered;
    }



    get processedArts() {
        if (!this.artigos) {
            return [];
        }

        return this.artigos.map(art => {
            const isOpen = art.isOpen || false;

            return {
                ...art,
                isOpen: isOpen,
                containerClass: isOpen ? 'secondContainer open' : 'secondContainer',
                iconClass: isOpen ? 'iconDrop open slds-current-color' : 'iconDrop slds-current-color',
                questoes: art.questoes.map(q => {
                    const isHighlighted = q.isHighlighted || false;
                    // console.log(isHighlighted);

                    return {
                        ...q,
                        isHighlighted: isHighlighted,
                        questionClass: isHighlighted ? 'questionClass open' : 'questionClass',
                        itemClass: isHighlighted ? 'menuCardContainer open' : 'menuCardContainer'

                    };
                })
            };
        });
    }


    processedArtsFilter() {
        if (!this.artigos) {
            return [];
        }

        return this.artigos.map(artigo => {
            return {
                ...artigo, tema: this.stripHtml(artigo.tema),
                questoes: artigo.questoes.map(q => {
                    return {
                        ...q, titulo: this.stripHtml(q.titulo),
                        conteudo: this.stripHtmlAndPreserveLineBreaks(q.conteudo) // ele está aqui, dentro deum map que está dentro de outro map
                    };
                })
            };
        })

    }





}