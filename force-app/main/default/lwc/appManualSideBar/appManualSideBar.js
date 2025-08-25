import { LightningElement, wire, track } from 'lwc';
import getArtigosComQuestoesDTO from '@salesforce/apex/APP_CommunityManualController.getArtigosComQuestoesDTO';

export default class AppManualSidebar extends LightningElement {
    artigos;

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
        } else if (error) { console.error(error); }
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

        // Log para ver o que a função está recebendo
        console.log('HTML de entrada:', htmlString);

        const parser = new DOMParser();
        const doc = parser.parseFromString(htmlString, 'text/html');
        const paragraphs = doc.querySelectorAll('p');
        const result = Array.from(paragraphs)
            .map(p => p.textContent || '')
            .join('\n');

        // Log para ver o que a função está retornando
        console.log('Texto de saída:', result);

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
                    console.log(isHighlighted);

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

}