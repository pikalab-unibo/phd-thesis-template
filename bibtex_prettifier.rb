require 'bibtex'

# Separate acronym definitions from actual references
def separate_acronyms(bib)
  acronyms = BibTeX::Bibliography.new
  references = BibTeX::Bibliography.new

  bib.each do |entry|
    # Check if the entry is an acronym definition, e.g., using '@string'
    if entry.type.to_s.downcase == 'string' || entry.type.to_s.downcase == 'acronym'
      acronyms << entry
    else
      references << entry
    end
  end

  return acronyms, references
end

# Remove 'url' if 'doi' is present
def remove_redundant_url(bib)
  bib.each do |entry|
    next unless entry.is_a?(BibTeX::Entry)

    if entry.has_field?('doi') && entry.has_field?('url')
      entry.delete('url')
    end
  end
end

# Remove duplicates by comparing relevant fields and unique identifiers
def remove_duplicates(bib)
  seen_entries = {}
  unique_entries = BibTeX::Bibliography.new

  bib.each do |entry|
    # Ensure the entry is a BibTeX::Entry object
    next unless entry.is_a?(BibTeX::Entry)

    # Generate a unique key based on relevant fields (e.g., title, doi, author)
    key_fields = ['title', 'doi', 'isbn', 'issn', 'author']

    # Build a unique identifier for each entry by checking all possible fields
    key = key_fields.map { |field| entry[field].to_s if entry.has_field?(field) }.compact.join('|')

    # Only add the entry if it hasn't been seen before
    unless seen_entries[key]
      seen_entries[key] = true
      unique_entries << entry
    end
  end

  # Return the new bibliography with unique entries
  unique_entries
end

# Load BibTeX file
bibfile = "phd-thesis.bib"
bib = BibTeX.open(bibfile)

# Separate acronym definitions from actual references
acronyms, references = separate_acronyms(bib)

# Clean the bibliography (remove duplicates and redundant URLs)
references = remove_duplicates(references)
remove_redundant_url(references)

# Overwrite the original file with acronyms followed by cleaned references
output_file = "phd-thesis.bib"
File.open(output_file, 'w') do |f|
  f.write(acronyms.to_s)     # Write the acronym definitions first
  f.write(references.to_s)   # Write the cleaned references
end

puts "BibTeX file #{output_file} has been updated"