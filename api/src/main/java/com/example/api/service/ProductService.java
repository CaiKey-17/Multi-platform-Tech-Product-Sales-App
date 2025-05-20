package com.example.api.service;

import com.example.api.dto.*;
import com.example.api.model.Product;
import com.example.api.model.Product_color;
import com.example.api.model.Product_image;
import com.example.api.model.Product_variant;
import com.example.api.repository.ProductColorRepository;
import com.example.api.repository.ProductImageRepository;
import com.example.api.repository.ProductRepository;
import com.example.api.repository.ProductVariantRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.stream.Collectors;

@Service
public class ProductService {

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private ProductVariantRepository productVariantRepository;

    @Autowired
    private ProductImageRepository productImageRepository;

    @Autowired
    private ProductColorRepository productColorRepository;

    public List<ProductDTO> getAllProductsNew() {
        List<Product> products = productRepository.findTop20ByOrderByCreatedAtDesc();
        List<ProductDTO> productDTOs = new ArrayList<>();

        for (Product product : products) {
            List<Product_variant> variants = productVariantRepository.findByFkVariantProduct(product.getId());
            if (!variants.isEmpty()) {
                Product_variant variant = variants.get(0);
                List<Product_color> colors = productColorRepository.findByFkVariantProduct(variant.getId());


                ProductDTO dto = new ProductDTO();
                dto.setId(product.getId());
                double avgRating = productRepository.findAvgRatingByProductId(product.getId());
                dto.setRating(avgRating);
                dto.setImage(product.getMainImage());
                NumberFormat currencyFormatter = NumberFormat.getNumberInstance(Locale.GERMANY);
                DecimalFormat decimalFormat = (DecimalFormat) currencyFormatter;
                decimalFormat.applyPattern("#,### đ");
                double discountAmount = variant.getOriginalPrice() - variant.getPrice();
                dto.setDiscountLabel("TIẾT KIỆM\n" + decimalFormat.format(discountAmount));
                dto.setName(product.getName());
                dto.setDescription(product.getShortDescription());
                dto.setPrice(variant.getPrice());
                dto.setOldPrice(variant.getOriginalPrice());
                dto.setDiscountPercent(variant.getDiscountPercent());
                dto.setIdVariant(variant.getId());

                if (!colors.isEmpty()) {
                    dto.setIdColor(colors.get(0).getId());
                } else {
                    dto.setIdColor(-1);
                }

                productDTOs.add(dto);
            }

        }

        return productDTOs;
    }



    public List<ProductDTO> getAllProductsLaptop() {
        List<Product> products = productRepository.findByFkCategory("Laptop");
        List<ProductDTO> productDTOs = new ArrayList<>();

        for (Product product : products) {
            List<Product_variant> variants = productVariantRepository.findByFkVariantProduct(product.getId());
            if (!variants.isEmpty()) {
                Product_variant variant = variants.get(0);
                List<Product_color> colors = productColorRepository.findByFkVariantProduct(variant.getId());


                ProductDTO dto = new ProductDTO();
                dto.setId(product.getId());
                Double avgRating = productRepository.findAvgRatingByProductId(product.getId());
                dto.setRating(avgRating);
                dto.setImage(product.getMainImage());
                NumberFormat currencyFormatter = NumberFormat.getNumberInstance(Locale.GERMANY);
                DecimalFormat decimalFormat = (DecimalFormat) currencyFormatter;
                decimalFormat.applyPattern("#,### đ");
                double discountAmount = variant.getOriginalPrice() - variant.getPrice();
                dto.setDiscountLabel("TIẾT KIỆM\n" + decimalFormat.format(discountAmount));
                dto.setName(product.getName());
                dto.setDescription(product.getShortDescription());
                dto.setPrice(variant.getPrice());
                dto.setOldPrice(variant.getOriginalPrice());
                dto.setDiscountPercent(variant.getDiscountPercent());
                dto.setIdVariant(variant.getId());

                if (!colors.isEmpty()) {
                    dto.setIdColor(colors.get(0).getId());
                } else {
                    dto.setIdColor(-1);
                }

                productDTOs.add(dto);
            }

        }

        return productDTOs;
    }

    public List<ProductDTO> getAllProductsMonitor() {
        List<Product> products = productRepository.findByFkCategory("Màn hình");
        List<ProductDTO> productDTOs = new ArrayList<>();

        for (Product product : products) {
            List<Product_variant> variants = productVariantRepository.findByFkVariantProduct(product.getId());
            if (!variants.isEmpty()) {
                Product_variant variant = variants.get(0);
                List<Product_color> colors = productColorRepository.findByFkVariantProduct(variant.getId());


                ProductDTO dto = new ProductDTO();
                dto.setId(product.getId());
                Double avgRating = productRepository.findAvgRatingByProductId(product.getId());
                dto.setRating(avgRating);
                dto.setImage(product.getMainImage());
                NumberFormat currencyFormatter = NumberFormat.getNumberInstance(Locale.GERMANY);
                DecimalFormat decimalFormat = (DecimalFormat) currencyFormatter;
                decimalFormat.applyPattern("#,### đ");
                double discountAmount = variant.getOriginalPrice() - variant.getPrice();
                dto.setDiscountLabel("TIẾT KIỆM\n" + decimalFormat.format(discountAmount));
                dto.setName(product.getName());
                dto.setDescription(product.getShortDescription());
                dto.setPrice(variant.getPrice());
                dto.setOldPrice(variant.getOriginalPrice());
                dto.setDiscountPercent(variant.getDiscountPercent());
                dto.setIdVariant(variant.getId());

                if (!colors.isEmpty()) {
                    dto.setIdColor(colors.get(0).getId());
                } else {
                    dto.setIdColor(-1);
                }

                productDTOs.add(dto);
            }

        }

        return productDTOs;
    }

    public List<ProductDTO> getAllProductsPc() {
        List<Product> products = productRepository.findByFkCategory("PC - Máy tính bàn");
        List<ProductDTO> productDTOs = new ArrayList<>();

        for (Product product : products) {
            List<Product_variant> variants = productVariantRepository.findByFkVariantProduct(product.getId());
            if (!variants.isEmpty()) {
                Product_variant variant = variants.get(0);
                List<Product_color> colors = productColorRepository.findByFkVariantProduct(variant.getId());


                ProductDTO dto = new ProductDTO();
                dto.setId(product.getId());
                Double avgRating = productRepository.findAvgRatingByProductId(product.getId());
                dto.setRating(avgRating);
                dto.setImage(product.getMainImage());
                NumberFormat currencyFormatter = NumberFormat.getNumberInstance(Locale.GERMANY);
                DecimalFormat decimalFormat = (DecimalFormat) currencyFormatter;
                decimalFormat.applyPattern("#,### đ");
                double discountAmount = variant.getOriginalPrice() - variant.getPrice();
                dto.setDiscountLabel("TIẾT KIỆM\n" + decimalFormat.format(discountAmount));
                dto.setName(product.getName());
                dto.setDescription(product.getShortDescription());
                dto.setPrice(variant.getPrice());
                dto.setOldPrice(variant.getOriginalPrice());
                dto.setDiscountPercent(variant.getDiscountPercent());
                dto.setIdVariant(variant.getId());

                if (!colors.isEmpty()) {
                    dto.setIdColor(colors.get(0).getId());
                } else {
                    dto.setIdColor(-1);
                }

                productDTOs.add(dto);
            }

        }

        return productDTOs;
    }

    public List<ProductDTO> getAllProductsPhone() {
        List<Product> products = productRepository.findByFkCategory("Điện thoại");
        List<ProductDTO> productDTOs = new ArrayList<>();

        for (Product product : products) {
            List<Product_variant> variants = productVariantRepository.findByFkVariantProduct(product.getId());
            if (!variants.isEmpty()) {
                Product_variant variant = variants.get(0);
                List<Product_color> colors = productColorRepository.findByFkVariantProduct(variant.getId());


                ProductDTO dto = new ProductDTO();
                dto.setId(product.getId());
                Double avgRating = productRepository.findAvgRatingByProductId(product.getId());
                dto.setRating(avgRating);
                dto.setImage(product.getMainImage());
                NumberFormat currencyFormatter = NumberFormat.getNumberInstance(Locale.GERMANY);
                DecimalFormat decimalFormat = (DecimalFormat) currencyFormatter;
                decimalFormat.applyPattern("#,### đ");
                double discountAmount = variant.getOriginalPrice() - variant.getPrice();
                dto.setDiscountLabel("TIẾT KIỆM\n" + decimalFormat.format(discountAmount));
                dto.setName(product.getName());
                dto.setDescription(product.getShortDescription());
                dto.setPrice(variant.getPrice());
                dto.setOldPrice(variant.getOriginalPrice());
                dto.setDiscountPercent(variant.getDiscountPercent());
                dto.setIdVariant(variant.getId());

                if (!colors.isEmpty()) {
                    dto.setIdColor(colors.get(0).getId());
                } else {
                    dto.setIdColor(-1);
                }

                productDTOs.add(dto);
            }

        }

        return productDTOs;
    }

    public List<ProductDTO> getAllProductsKeyboard() {
        List<Product> products = productRepository.findByFkCategory("Bàn phím");
        List<ProductDTO> productDTOs = new ArrayList<>();

        for (Product product : products) {
            List<Product_variant> variants = productVariantRepository.findByFkVariantProduct(product.getId());
            if (!variants.isEmpty()) {
                Product_variant variant = variants.get(0);
                List<Product_color> colors = productColorRepository.findByFkVariantProduct(variant.getId());


                ProductDTO dto = new ProductDTO();
                dto.setId(product.getId());
                Double avgRating = productRepository.findAvgRatingByProductId(product.getId());
                dto.setRating(avgRating);
                dto.setImage(product.getMainImage());
                NumberFormat currencyFormatter = NumberFormat.getNumberInstance(Locale.GERMANY);
                DecimalFormat decimalFormat = (DecimalFormat) currencyFormatter;
                decimalFormat.applyPattern("#,### đ");
                double discountAmount = variant.getOriginalPrice() - variant.getPrice();
                dto.setDiscountLabel("TIẾT KIỆM\n" + decimalFormat.format(discountAmount));
                dto.setName(product.getName());
                dto.setDescription(product.getShortDescription());
                dto.setPrice(variant.getPrice());
                dto.setOldPrice(variant.getOriginalPrice());
                dto.setDiscountPercent(variant.getDiscountPercent());
                dto.setIdVariant(variant.getId());

                if (!colors.isEmpty()) {
                    dto.setIdColor(colors.get(0).getId());
                } else {
                    dto.setIdColor(-1);
                }

                productDTOs.add(dto);
            }

        }

        return productDTOs;
    }



    public List<ProductDTO> getAllProductsBestSeller(){
        List<Product> products = productRepository.findTop20BestSeller();
        List<ProductDTO> productDTOs = new ArrayList<>();

        for (Product product : products) {
            List<Product_variant> variants = productVariantRepository.findByFkVariantProduct(product.getId());
            if (!variants.isEmpty()) {
                Product_variant variant = variants.get(0);
                List<Product_color> colors = productColorRepository.findByFkVariantProduct(variant.getId());


                ProductDTO dto = new ProductDTO();
                dto.setId(product.getId());
                Double avgRating = productRepository.findAvgRatingByProductId(product.getId());
                dto.setRating(avgRating);
                dto.setImage(product.getMainImage());
                NumberFormat currencyFormatter = NumberFormat.getNumberInstance(Locale.GERMANY);
                DecimalFormat decimalFormat = (DecimalFormat) currencyFormatter;
                decimalFormat.applyPattern("#,### đ");
                double discountAmount = variant.getOriginalPrice() - variant.getPrice();
                dto.setDiscountLabel("TIẾT KIỆM\n" + decimalFormat.format(discountAmount));
                dto.setName(product.getName());
                dto.setDescription(product.getShortDescription());
                dto.setPrice(variant.getPrice());
                dto.setOldPrice(variant.getOriginalPrice());
                dto.setDiscountPercent(variant.getDiscountPercent());
                dto.setIdVariant(variant.getId());

                if (!colors.isEmpty()) {
                    dto.setIdColor(colors.get(0).getId());
                } else {
                    dto.setIdColor(-1);
                }

                productDTOs.add(dto);
            }

        }

        return productDTOs;
    }

    public List<ProductDTO> getAllProductsPromotion() {
        List<Product> products = productRepository.findAll();
        List<ProductDTO> productDTOs = new ArrayList<>();

        for (Product product : products) {
            List<Product_variant> variants = productVariantRepository.findByFkVariantProduct(product.getId());
            if (!variants.isEmpty() ) {
                for(Product_variant j:variants){
                    if(j.getDiscountPercent()>10){
                        List<Product_color> colors = productColorRepository.findByFkVariantProduct(j.getId());


                        ProductDTO dto = new ProductDTO();
                        dto.setId(product.getId());
                        Double avgRating = productRepository.findAvgRatingByProductId(product.getId());
                        dto.setRating(avgRating);
                        dto.setImage(product.getMainImage());
                        NumberFormat currencyFormatter = NumberFormat.getNumberInstance(Locale.GERMANY);
                        DecimalFormat decimalFormat = (DecimalFormat) currencyFormatter;
                        decimalFormat.applyPattern("#,### đ");
                        double discountAmount = j.getOriginalPrice() - j.getPrice();
                        dto.setDiscountLabel("TIẾT KIỆM\n" + decimalFormat.format(discountAmount));
                        dto.setName(product.getName());
                        dto.setDescription(product.getShortDescription());
                        dto.setPrice(j.getPrice());
                        dto.setOldPrice(j.getOriginalPrice());
                        dto.setDiscountPercent(j.getDiscountPercent());
                        dto.setIdVariant(j.getId());

                        if (!colors.isEmpty()) {
                            dto.setIdColor(colors.get(0).getId());
                        } else {
                            dto.setIdColor(-1);
                        }

                        productDTOs.add(dto);
                        break;
                    }
                }
            }

        }

        return productDTOs;
    }
    public List<ProductDTO> getAllProductsByCategory(String fk_category) {
        List<Product> products = productRepository.findByFkCategory(fk_category);
        List<ProductDTO> productDTOs = new ArrayList<>();

        for (Product product : products) {
            List<Product_variant> variants = productVariantRepository.findByFkVariantProduct(product.getId());
            if (!variants.isEmpty()) {
                Product_variant variant = variants.get(0);
                List<Product_color> colors = productColorRepository.findByFkVariantProduct(variant.getId());
                ProductDTO dto = new ProductDTO();
                dto.setId(product.getId());
                Double avgRating = productRepository.findAvgRatingByProductId(product.getId());
                dto.setRating(avgRating);
                dto.setImage(product.getMainImage());

                NumberFormat currencyFormatter = NumberFormat.getNumberInstance(Locale.GERMANY);
                DecimalFormat decimalFormat = (DecimalFormat) currencyFormatter;
                decimalFormat.applyPattern("#,### đ");
                double discountAmount = variant.getOriginalPrice() - variant.getPrice();
                dto.setDiscountLabel("TIẾT KIỆM\n" + decimalFormat.format(discountAmount));
                dto.setName(product.getName());
                dto.setDescription(product.getShortDescription());
                dto.setPrice(variant.getPrice());
                dto.setOldPrice(variant.getOriginalPrice());
                dto.setDiscountPercent(variant.getDiscountPercent());
                dto.setIdVariant(variant.getId());
                if (!colors.isEmpty()) {
                    dto.setIdColor(colors.get(0).getId());
                } else {
                    dto.setIdColor(-1);
                }

                productDTOs.add(dto);
            }

        }

        return productDTOs;
    }

    public List<ProductDTO> getAllProductsByBrand(String fk_brand) {
        List<Product> products = productRepository.findByFkBrand(fk_brand);
        List<ProductDTO> productDTOs = new ArrayList<>();

        for (Product product : products) {
            List<Product_variant> variants = productVariantRepository.findByFkVariantProduct(product.getId());
            if (!variants.isEmpty()) {
                Product_variant variant = variants.get(0);
                List<Product_color> colors = productColorRepository.findByFkVariantProduct(variant.getId());
                ProductDTO dto = new ProductDTO();
                dto.setId(product.getId());
                Double avgRating = productRepository.findAvgRatingByProductId(product.getId());
                dto.setRating(avgRating);
                dto.setImage(product.getMainImage());

                NumberFormat currencyFormatter = NumberFormat.getNumberInstance(Locale.GERMANY);
                DecimalFormat decimalFormat = (DecimalFormat) currencyFormatter;
                decimalFormat.applyPattern("#,### đ");

                double discountAmount = variant.getOriginalPrice() - variant.getPrice();
                dto.setDiscountLabel("TIẾT KIỆM\n" + decimalFormat.format(discountAmount));
                dto.setName(product.getName());
                dto.setDescription(product.getShortDescription());
                dto.setPrice(variant.getPrice());
                dto.setOldPrice(variant.getOriginalPrice());
                dto.setDiscountPercent(variant.getDiscountPercent());
                dto.setIdVariant(variant.getId());
                if (!colors.isEmpty()) {
                    dto.setIdColor(colors.get(0).getId());
                } else {
                    dto.setIdColor(-1);
                }

                productDTOs.add(dto);
            }

        }

        return productDTOs;
    }
    public ProductDetailDTO getDetailProduct(int id) {
        Product product = productRepository.findById(id).orElse(null);
        if (product == null) {
            return null;
        }

        ProductDetailDTO productDTO = new ProductDetailDTO();
        productDTO.setId(product.getId());
        Double avgRating = productRepository.findAvgRatingByProductId(product.getId());
        productDTO.setRating(avgRating);
        productDTO.setName(product.getName());
        productDTO.setBrand(product.getFkBrand());
        productDTO.setCategory(product.getFkCategory());

        if(product.getShortDescription()!=null){
            productDTO.setDescription(product.getShortDescription());
        }
        else{
            productDTO.setDescription("");
        }

        if(product.getDetail()!=null){
            productDTO.setDetail(product.getDetail());
        }
        else{
            productDTO.setDetail("");
        }


        List<ImageDTO> imageDTOs = productImageRepository.findByFkImageProduct(product.getId()).stream()
                .map(image -> {
                    ImageDTO imgDto = new ImageDTO();
                    imgDto.setId(image.getId());
                    imgDto.setImage(image.getImage());
                    return imgDto;
                })
                .collect(Collectors.toList());
        productDTO.setImages(imageDTOs);

        List<VariantDTO> variantDTOs = productVariantRepository.findByFkVariantProduct(product.getId()).stream()
                .map(variant -> {
                    VariantDTO variantDTO = new VariantDTO();
                    variantDTO.setId(variant.getId());
                    variantDTO.setName(variant.getNameVariant());
                    variantDTO.setDiscountPercent(variant.getDiscountPercent());
                    variantDTO.setOldPrice(variant.getOriginalPrice());
                    variantDTO.setPrice(variant.getPrice());

                    List<ColorDTO> colorDTOs = productColorRepository.findByFkVariantProduct(variant.getId()).stream()
                            .map(color -> {
                                ColorDTO colorDTO = new ColorDTO();
                                colorDTO.setId(color.getId());
                                colorDTO.setName_color(color.getColorName());
                                colorDTO.setPrice(color.getColorPrice());
                                colorDTO.setImage(color.getImage());
                                return colorDTO;
                            })
                            .collect(Collectors.toList());

                    variantDTO.setColors(colorDTOs);
                    return variantDTO;
                })
                .collect(Collectors.toList());

        productDTO.setVariants(variantDTOs);


        return productDTO;
    }


    public List<ProductDTO> getAllProductsBySearch(String name) {
        List<Product> products = productRepository.findByNameContainingIgnoreCase(name);
        List<ProductDTO> productDTOs = new ArrayList<>();

        for (Product product : products) {
            List<Product_variant> variants = productVariantRepository.findByFkVariantProduct(product.getId());
            if (!variants.isEmpty()) {
                Product_variant variant = variants.get(0);
                List<Product_color> colors = productColorRepository.findByFkVariantProduct(variant.getId());
                ProductDTO dto = new ProductDTO();
                dto.setId(product.getId());
                Double avgRating = productRepository.findAvgRatingByProductId(product.getId());
                dto.setRating(avgRating);
                dto.setImage(product.getMainImage());

                NumberFormat currencyFormatter = NumberFormat.getNumberInstance(Locale.GERMANY);
                DecimalFormat decimalFormat = (DecimalFormat) currencyFormatter;
                decimalFormat.applyPattern("#,### đ");

                double discountAmount = variant.getOriginalPrice() - variant.getPrice();
                dto.setDiscountLabel("TIẾT KIỆM\n" + decimalFormat.format(discountAmount));
                dto.setName(product.getName());
                dto.setDescription(product.getShortDescription());
                dto.setPrice(variant.getPrice());
                dto.setOldPrice(variant.getOriginalPrice());
                dto.setDiscountPercent(variant.getDiscountPercent());
                dto.setIdVariant(variant.getId());
                if (!colors.isEmpty()) {
                    dto.setIdColor(colors.get(0).getId());
                } else {
                    dto.setIdColor(-1);
                }

                productDTOs.add(dto);
            }

        }

        return productDTOs;
    }

    public List<ProductDTO> getAllProductsBySearchAdvance(String name, String brand, Double minPrice, Double maxPrice, Double rating) {
        List<Product> products = productRepository.findByNameContainingIgnoreCase(name);
        List<ProductDTO> productDTOs = new ArrayList<>();

        for (Product product : products) {
            if (brand != null && !brand.isEmpty() && !brand.equalsIgnoreCase(product.getFkBrand())) {
                continue;
            }

            List<Product_variant> variants = productVariantRepository.findByFkVariantProduct(product.getId());
            if (!variants.isEmpty()) {
                Product_variant variant = variants.get(0);
                double price = variant.getPrice();

                if (minPrice != null && price < minPrice) continue;
                if (maxPrice != null && price > maxPrice) continue;

                Double avgRating = productRepository.findAvgRatingByProductId(product.getId());
                if (rating != null && (avgRating == null || !avgRating.equals(rating))) continue;

                List<Product_color> colors = productColorRepository.findByFkVariantProduct(variant.getId());

                ProductDTO dto = new ProductDTO();
                dto.setId(product.getId());
                dto.setRating(avgRating != null ? avgRating : 0);
                dto.setImage(product.getMainImage());

                NumberFormat currencyFormatter = NumberFormat.getNumberInstance(Locale.GERMANY);
                DecimalFormat decimalFormat = (DecimalFormat) currencyFormatter;
                decimalFormat.applyPattern("#,### đ");

                double discountAmount = variant.getOriginalPrice() - variant.getPrice();
                dto.setDiscountLabel("TIẾT KIỆM\n" + decimalFormat.format(discountAmount));
                dto.setName(product.getName());
                dto.setDescription(product.getShortDescription());
                dto.setPrice(variant.getPrice());
                dto.setOldPrice(variant.getOriginalPrice());
                dto.setDiscountPercent(variant.getDiscountPercent());
                dto.setIdVariant(variant.getId());
                dto.setIdColor(!colors.isEmpty() ? colors.get(0).getId() : -1);

                productDTOs.add(dto);
            }
        }

        return productDTOs;
    }


}
