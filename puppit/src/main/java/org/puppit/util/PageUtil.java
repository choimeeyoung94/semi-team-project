package org.puppit.util;

import java.util.Map;

import org.puppit.model.dto.PageDTO;
import org.springframework.stereotype.Component;

@Component
public class PageUtil {
	  //----- �� ��� �� ǥ���� �������� ����
	  private static final int PAGE_PER_BLOCK = 10;
	 
	  /**
	   * ����¡ ������ ����ؼ� PageDTO�� �����ϴ� �޼ҵ�
	   */
	  public void calculatePaging(PageDTO dto) {
	    int page = dto.getPage();
	    int size = dto.getSize();
	    int itemCount = dto.getItemCount();
	    
	    int offset = (page - 1) * size;
	    int pageCount = (int) Math.ceil((double) itemCount / size);
	    int beginPage = ((page - 1) / PAGE_PER_BLOCK) * PAGE_PER_BLOCK + 1;
	    int endPage = Math.min(beginPage + PAGE_PER_BLOCK - 1, pageCount);
	    
	    dto.setOffset(offset);
	    dto.setPageCount(pageCount);
	    dto.setBeginPage(beginPage);
	    dto.setEndPage(endPage);
	  }
	  
	  /**
	   * ������ �̵� ��ũ(HTML) ����
	   */
	  public String getPagingHtml(PageDTO dto, String requestURL, Map<String, Object> params) {
	    
	    //----- ������ �̵� ��ũ ������ �ʿ��� ����
	    int page = dto.getPage();
	    int pageCount = dto.getPageCount();
	    int beginPage = dto.getBeginPage();
	    int endPage = dto.getEndPage();
	    
	    //----- ���� ��Ʈ�� �����
	    String queryString = "";
	    if (params != null) {
	      StringBuilder queryStringBuilder = new StringBuilder();
	      for (Map.Entry<String, Object> entry : params.entrySet()) {
	        queryStringBuilder.append("&");
	        queryStringBuilder.append(entry.getKey());
	        queryStringBuilder.append("=");      
	        queryStringBuilder.append(entry.getValue());      
	      }
	      queryString = queryStringBuilder.toString();
	    }
	    
	    StringBuilder builder = new StringBuilder();
	    
	    //----- ��Ÿ�� ���� ����
	    builder.append("<style>");
	    builder.append(".pagination { display: flex; justify-content: center; width: 400px; margin: 0 auto; }");
	    builder.append(".pagination button { display: block; border: none; background-color: #fff; text-align: center; width: 30px; height: 30px; line-height: 30px; cursor: pointer; }");
	    builder.append(".pagination .disabled-button { color: silver; cursor: auto; }");
	    builder.append(".pagination .focus-page { color: limegreen; }");
	    builder.append("</style>");
	    
	    //----- <div class="pagination">
	    builder.append("<div class=\"pagination\">");
	    
	    //----- ���� ��� ( < )
	    if(beginPage == 1)
	      builder.append("<button type=\"button\" class=\"disabled-button\">&lt;</button>");
	    else
	      builder.append("<button type=\"button\" onclick=\"location.href='" + requestURL + "?page=" + (beginPage - 1) + queryString + "'\">&lt;</button>");
	    
	    //----- ������ ( 1 2 3 4 5 6 7 8 9 10 )
	    for (int p = beginPage; p <= endPage; p++) {
	      if (p == page)
	        builder.append("<button type=\"button\" class=\"focus-page\" onclick=\"location.href='" + requestURL + "?page=" + (p) + queryString + "'\">" + p + "</button>");
	      else
	        builder.append("<button type=\"button\" onclick=\"location.href='" + requestURL + "?page=" + (p) + queryString + "'\">" + p + "</button>");        
	    }
	    
	    //----- ���� ��� ( > )
	    if(endPage == pageCount)
	      builder.append("<button type=\"button\" class=\"disabled-button\">&gt;</button>");
	    else
	      builder.append("<button type=\"button\" onclick=\"location.href='" + requestURL + "?page=" + (endPage + 1) + queryString + "'\">&gt;</button>");
	    
	    //----- </div>
	    builder.append("</div>");
	    
	    return builder.toString();
	    
	  }
}
