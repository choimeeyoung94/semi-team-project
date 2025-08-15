package org.puppit.controller;


import org.puppit.model.dto.ProductDTO;
import org.puppit.model.dto.ProductImageDTO;
import org.puppit.model.dto.ProductSearchDTO;
import org.puppit.service.ProductService;
import org.puppit.service.S3Service;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import lombok.RequiredArgsConstructor;

import javax.servlet.http.HttpSession;
import java.util.List;
import java.util.Map;

@Controller
@RequiredArgsConstructor
@RequestMapping("/product")
public class ProductController {

    private final ProductService productService;
    private final S3Service s3Service;

    /** ��ǰ ��� �� */
    @GetMapping("/new")
    public String newForm(ProductDTO productDTO, Model model, HttpSession session,
                          RedirectAttributes ra) {
        Object attr = session.getAttribute("sessionMap");
        Map<String, Object> map = (Map<String, Object>)attr;
        Integer sellerId = (Integer) map.get("userId");


        if (sellerId == null) {
            ra.addFlashAttribute("error", "��ǰ ����� �α��� �� �̿� �����մϴ�.");
            return "redirect:/user/login";
        }



        // ����Ʈ �ڽ� ������
        var formData = productService.getProductFormData();
        model.addAttribute("categories", formData.get("categories"));
        model.addAttribute("locations", formData.get("locations"));
        model.addAttribute("conditions", formData.get("conditions"));
        model.addAttribute("product", new ProductDTO());

        return "product/productForm";
    }

    @PostMapping("/new")
    public String create(@ModelAttribute ProductDTO product,
                         @RequestParam("imageFiles") List<MultipartFile> imageFiles,
                         @RequestParam(value="attachment", required=false) MultipartFile attachment,
                         HttpSession session,
                         RedirectAttributes ra) {

        // 1. �α��� ����� Ȯ��
        Object attr = session.getAttribute("sessionMap");
        Map<String, Object> map = (Map<String, Object>)attr;
        Integer sellerId = (Integer) map.get("userId");

        if (sellerId == null) {
            ra.addFlashAttribute("error", "��ǰ ����� �α��� �� �̿� �����մϴ�.");
            return "redirect:/user/login";
        }

        // 2. �Ǹ��� ID ����
        product.setSellerId(sellerId);

        // 3. ���� �⺻�� ���� (�Ǹ���)
        if (product.getStatusId() == null) {
            product.setStatusId(1);
        }

        try {
            // 4. ���� ȣ�� (��ǰ + �̹��� ���)
            productService.registerProduct(product, imageFiles);

            // 5. ���� �޽���
            ra.addFlashAttribute("success", "��ǰ�� ��ϵǾ����ϴ�.");
            return "redirect:/product/myproduct";

        } catch (RuntimeException e) {
            // 6. ���� ó��
            ra.addFlashAttribute("error", "��ǰ ��� �� ������ �߻��߽��ϴ�: " + e.getMessage());
            return "redirect:/product/new";
        }
    }


    @GetMapping("/detail/{productId}")
    public String getProductDetail(@PathVariable int productId, Model model) {
        var productDetail = productService.getProductDetail(productId); // ����
        if (productDetail == null) { // ����
            model.addAttribute("error", "�ش� ��ǰ�� ã�� �� �����ϴ�.");
            return "error/404";
        }
        System.out.println("product: " + productDetail.toString());
        model.addAttribute("product", productDetail);
        return "product/detail";
    }

    @GetMapping("/product/scroll")
    public String scrollList() {
        return "product/scroll";
    }

    @GetMapping("/myproduct")
    public String myProduct(HttpSession session, RedirectAttributes ra, Model model) {


        Object attr = session.getAttribute("sessionMap");
        if (attr == null) {
            ra.addFlashAttribute("error", "��ǰ ������ �α��� �� �̿� �����մϴ�.");
            return "redirect:/user/login";
        }

        Map<String, Object> map = (Map<String, Object>)attr;
        Integer sellerId = (Integer) map.get("userId");

        List<ProductDTO> items = productService.selectMyProducts(sellerId);
        model.addAttribute("items", items);

        return "product/myproduct";
    }
    
    @GetMapping(value = "/search", produces = "application/json; charset=UTF-8")
    @ResponseBody
    public List<ProductSearchDTO> searchByNew(@RequestParam String searchName) {
        return productService.searchByNew(searchName);
    }


    
}