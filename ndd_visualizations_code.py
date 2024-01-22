# Original done in Google Colab/Jupyter Notebooks 

import pandas as pd
import networkx as nx
import matplotlib.pyplot as plt
import textwrap

# Average Confidence for Different Diseases

import matplotlib.pyplot as plt

avg_confidence = [0.901999998092651, 0.907142852033888, 0.882068971107746]
disease_name = ["Alzheimer's", "Huntington's", "Parkinson's"]

plt.bar(disease_name, avg_confidence, color=['blue', 'green', 'red'])

plt.xlabel('Disease Name')
plt.ylabel('Average Confidence')
plt.title('Average Confidence for Different Diseases')
plt.show()

# Diseases and Corresponding Genes - Network Diagram

genes = ['gene_a', 'gene_b']

for gene in genes:
    # Read data from CSV file into a pandas DataFrame
    df = pd.read_csv("disease_gene.csv")

    # Drop the 'positive_interaction' column

    # Count the occurrences of 'gene_b' for each 'disease_id'
    gene_counts = df.groupby(['disease_id', gene]).size().reset_index(name='count')

    # This can be altered if for the top _, right now it is top 5 genes per disease.
    top_genes_df = gene_counts.groupby('disease_id').head(5)

    # Create a directed graph
    G = nx.DiGraph()

    # Add nodes (disease and genes) and specify node colors
    node_colors = {}
    for node_type, node_data in [('disease_id', top_genes_df["disease_id"].unique()), (gene, top_genes_df[gene].unique())]:
        G.add_nodes_from(node_data, node_type=node_type)
        if node_type == 'disease_id':
            node_colors.update({node: 'lightblue' for node in node_data})
        else:
            node_colors.update({node: 'lightgreen' for node in node_data})

    # Add edges (disease-gene associations) without edge weights
    for _, row in top_genes_df.iterrows():
        G.add_edge(row["disease_id"], row[gene])

    # Use the hierarchical layout for a tree-like structure
    pos = nx.multipartite_layout(G, subset_key="node_type")

    # Increase vertical spacing by adjusting the figure size
    fig, ax = plt.subplots(figsize=(8, 13))  # Increase the height (vertical spacing) as needed

    # Draw the network diagram with different node colors and uniform edge width
    nx.draw(G, pos, with_labels=False, node_size=1000, node_color=[node_colors[node] for node in G.nodes()],
            font_size=10, font_color="black", font_weight="bold", width=1.0, edge_color="gray")  # Set width to 1.0

    # Add disease labels with wrapping
    disease_labels = {node: '\n'.join(textwrap.wrap(node, width=12)) for node in G.nodes() if node in top_genes_df["disease_id"].unique()}
    nx.draw_networkx_labels(G, pos, labels=disease_labels, font_size=8, font_color='black', font_weight='bold')

    # Add gene labels (for all genes)
    gene_labels = {node: node for node in G.nodes() if node in top_genes_df[gene].unique()}
    nx.draw_networkx_labels(G, pos, labels=gene_labels, font_size=8, font_color='black', font_weight='bold')

    # Add edge labels (num_appearances as weight labels)
    edge_labels = {edge: gene_counts[gene_counts['disease_id'] == edge[0]].loc[gene_counts[gene] == edge[1], 'count'].iloc[0] for edge in G.edges()}
    nx.draw_networkx_edge_labels(G, pos, edge_labels=edge_labels, font_size=10, font_color='red', font_weight='bold')

    # Legend
    disease_legend = plt.Line2D([0], [0], marker='o', color='w', label='Disease',
                               markersize=10, markerfacecolor='lightblue')
    gene_legend = plt.Line2D([0], [0], marker='o', color='w', label='Gene',
                             markersize=10, markerfacecolor='lightgreen')

    plt.legend(handles=[disease_legend, gene_legend], loc='upper right')

    # Wrap the title
    if gene == 'gene_a':
        title_text = "Top 5 Genes per Neurodegenerative Disease by Number of Associations (Gene A)"
    else:
        title_text = "Top 5 Genes per Neurodegenerative Disease by Number of Associations (Gene B)"
    wrapped_title = '\n'.join(textwrap.wrap(title_text, width=50))  # Adjust the width as needed
    plt.title(wrapped_title, fontsize=14)  # Increase the font size

    # Show the plot
    plt.show()

# Most Common Protein Counts For All 3 Diseases

protein_counts = {}

df = pd.read_csv("protein_counts.csv")

for index, row in df.iterrows():
    protein = row['protein']
    counts = row['count']

    # Check if the protein is already in the dictionary
    if protein in protein_counts:
        # If it's present, add the counts from the 'counts' column to the existing count
        protein_counts[protein] += counts
    else:
        # If it's not present, add it to the dictionary with the counts from the 'counts' column
        protein_counts[protein] = counts

# Create a DataFrame from the dictionary
unique_counts = pd.DataFrame(list(protein_counts.items()), columns=['protein', 'total_counts'])

unique_counts = unique_counts.sort_values(by='total_counts', ascending=False)

# Download Results
unique_counts.to_csv('unique_counts.csv', index=False)

from google.colab import files
files.download('unique_counts.csv')
