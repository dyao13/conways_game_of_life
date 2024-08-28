function fig = mat2fig(mat)
% Convert numeric matrix to grayscale figure.

    fig = imagesc(mat);
    colormap("gray")
    axis("equal");
    ylim([0.5, size(mat, 1)+0.5]);
    xlim([0.5, size(mat, 2)+0.5]);
end