package org.puppit.controller;

import org.puppit.model.dto.PageDTO;
import org.puppit.model.dto.ProductDTO;
import org.puppit.service.ProductService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import lombok.RequiredArgsConstructor;

import java.util.List;

@RequiredArgsConstructor
@Controller
public class MainController {
  
  private final ProductService productService;
  
  @RequestMapping(value = "/")
  public String main(Model model) {
    // ù ���� �� 8�� ��ǰ
    List<ProductDTO> initialProducts = productService.getProducts(0, 8);
    model.addAttribute("products", initialProducts);
    return "main";
  }

  // ��ũ��/������: offset�� size�� �޾Ƽ� ��ǰ ����Ʈ ��ȯ
  @GetMapping("/product/list")
  @ResponseBody
  public List<ProductDTO> getProducts(
      @RequestParam(defaultValue = "0") int offset,
      @RequestParam(defaultValue = "8") int size) {
    return productService.getProducts(offset, size);
  }
}