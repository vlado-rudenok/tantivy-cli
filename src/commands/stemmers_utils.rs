use tantivy::{
    tokenizer::{Language, LowerCaser, RemoveLongFilter, SimpleTokenizer, Stemmer, TextAnalyzer},
    Index,
};
use tantivy_stemmers::algorithms;

pub(crate) fn register_stem_tokenizers(index: &Index) {
    register_tantivy_languages(index);
    register_custom_languages(index);
}

fn register_tantivy_languages(index: &Index) {
    let languages = [
        ("ar_stem", Language::Arabic),
        ("de_stem", Language::German),
        ("en_stem", Language::English),
        ("es_stem", Language::Spanish),
        ("fin_stem", Language::Finnish),
        ("fr_stem", Language::French),
        ("hu_stem", Language::Hungarian),
        ("it_stem", Language::Italian),
        ("nl_stem", Language::Dutch),
        ("nn_stem", Language::Norwegian),
        ("pt_stem", Language::Portuguese),
        ("ro_stem", Language::Romanian),
        ("ru_stem", Language::Russian),
        ("sv_stem", Language::Swedish),
        ("ta_stem", Language::Tamil),
        ("tur_stem", Language::Turkish),
    ];

    for (name, language) in languages {
        register_stem_tokenizer(index, name, language);
    }
}

fn register_custom_languages(index: &Index) {
    register_language_tokenizer(&index, "cs_stem", algorithms::czech_dolamic_light);
    register_language_tokenizer(&index, "hi_stem", algorithms::hindi_lightweight);
    register_language_tokenizer(&index, "id_stem", algorithms::indonesian_tala);
    register_language_tokenizer(&index, "lit_stem", algorithms::lithuanian_jocas);
    register_language_tokenizer(&index, "ne_stem", algorithms::nepali);
    register_language_tokenizer(&index, "pl_stem", algorithms::polish_yarovoy_unaccented);
}

fn register_stem_tokenizer(index: &Index, name: &str, language: Language) {
    let tokenizer = TextAnalyzer::builder(SimpleTokenizer::default())
        .filter(RemoveLongFilter::limit(40))
        .filter(LowerCaser)
        .filter(Stemmer::new(language))
        .build();
    index.tokenizers().register(name, tokenizer);
}

fn register_language_tokenizer(
    index: &Index,
    name: &str,
    algorithm: tantivy_stemmers::algorithms::Algorithm,
) {
    let stemmer = tantivy_stemmers::StemmerTokenizer::new(algorithm);

    let tokenizer = TextAnalyzer::builder(SimpleTokenizer::default())
        .filter(LowerCaser)
        .filter(stemmer)
        .filter(RemoveLongFilter::limit(40))
        .build();

    // Register the tokenizer with the given name
    index.tokenizers().register(name, tokenizer);
}
