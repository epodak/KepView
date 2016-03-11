<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:servermain="http://www.kepware.com/schemas/servermain"
exclude-result-prefixes="xsl servermain">

  <xsl:template match="/">
    <div>
      <script type="text/javascript">


        opcSubscribe([
        <xsl:apply-templates select="servermain:Project/servermain:ChannelList/servermain:Channel" mode="opc"/>
        ]);
      </script>
			
    <div class="indent">
			<p/>
			<xsl:apply-templates mode="contents"/>
      <p/>
      <xsl:apply-templates/>
    </div>
  </div>
    <ul id="discussion"></ul>

  </xsl:template>
	<xsl:template mode="contents" match = "*"/>
	
	<xsl:template mode="contents" match = "
								servermain:Project 
								| servermain:ChannelList 
								| servermain:DeviceList
								| servermain:TagGroupList">
		<xsl:param name="tag-name"/>
		<xsl:apply-templates mode="contents">
			<xsl:with-param name="tag-name" select = "$tag-name" />
		</xsl:apply-templates>
	
	</xsl:template>

	<xsl:template  mode="contents"  match = "servermain:Channel 
								| servermain:Device
								| servermain:TagGroup
								| servermain:Tags">
		<xsl:param name="tag-name"/>
    <xsl:variable name='my-tag-name'>
      <xsl:if test='$tag-name'>
        <xsl:value-of select='concat($tag-name,".")'/>
      </xsl:if>
    </xsl:variable>
		<div>
			<a>
				<xsl:attribute name="href" >
					<xsl:value-of select="concat('#' ,$my-tag-name, servermain:Name/text())"/>
				</xsl:attribute>
				<xsl:value-of select = "local-name()"/>:
				<xsl:value-of select = "servermain:Name/text()"/>
			</a>
		</div>
		<div class="contents-indent">
			<xsl:if test='name()="servermain:Channel"'>
				<xsl:apply-templates mode='contents'>
					<xsl:with-param name='tag-name' select='servermain:Name/text()'/>
				</xsl:apply-templates>
			</xsl:if>
			<xsl:if test='name()="servermain:Device" or name()="servermain:TagGroup"'>
				<xsl:apply-templates mode='contents'>
					<xsl:with-param name='tag-name' select='concat($tag-name, ".", servermain:Name/text())'/>
				</xsl:apply-templates>
			</xsl:if>
			<xsl:if test='name()!="servermain:Channel" and name()!="servermain:Device" and name()!="servermain:TagGroup"'>
				<xsl:apply-templates mode='contents'>
					<xsl:with-param name='tag-name' select='$tag-name'/>
				</xsl:apply-templates>
			</xsl:if>
		</div>
	</xsl:template>
		<xsl:template match = "*"></xsl:template>
	<xsl:template match = "servermain:ChannelList 
								| servermain:DeviceList 
								| servermain:TagGroupList">
		<xsl:param name="tag-name"/>
    <xsl:apply-templates>
			<xsl:with-param name="tag-name" select = "$tag-name" />
		</xsl:apply-templates>
	</xsl:template>
		<xsl:template match = "servermain:Project 
								| servermain:Channel 
								| servermain:Device
								| servermain:TagGroup
								| servermain:Tags">
    <xsl:param name="tag-name"/>
    <xsl:if test='local-name()!="parsererror"'>
      <xsl:if test='local-name()!="Name"'>
        <xsl:if test='.//*[text()]'>
          <xsl:variable name='my-tag-name'>
            <xsl:if test='$tag-name'>
              <xsl:value-of select='concat($tag-name,".")'/>
            </xsl:if>
          </xsl:variable>
          <a >
            <xsl:attribute name='href'>
              <xsl:call-template name="replace">
                <xsl:with-param name="text" select="concat('/explore.', $my-tag-name, servermain:Name/text())" />
                <xsl:with-param name="replace" select="'.'" />
                <xsl:with-param name="thenreplace" select="'//'" />
                
                <xsl:with-param name="by" select="'/'" />
              </xsl:call-template>
            </xsl:attribute>
            <div class="title">
              <xsl:attribute name="id" >
                <xsl:value-of select="concat($my-tag-name, servermain:Name/text())"/>
              </xsl:attribute>
                <xsl:call-template name="SplitCamelCase">
                  <xsl:with-param name="text" select = "local-name()" />
                </xsl:call-template>
              <xsl:if test="@Name">
                :
                <xsl:value-of select = "@Name"/>  
              </xsl:if>
              <xsl:if test="./servermain:Name">
                :
                <xsl:value-of select = "servermain:Name"/>  
              </xsl:if>
            </div>
          </a>
    
          
          <div class="indent">
            <xsl:if test='name()="servermain:Channel"'>
              <xsl:apply-templates>
                <xsl:with-param name='tag-name' select='servermain:Name/text()'/>
              </xsl:apply-templates>
            </xsl:if>
            <xsl:if test='name()="servermain:Device" or name()="servermain:TagGroup"'>
              <xsl:apply-templates>
                <xsl:with-param name='tag-name' select='concat($tag-name, ".", servermain:Name/text())'/>
              </xsl:apply-templates>
            </xsl:if>
            <xsl:if test='name()!="servermain:Channel" and name()!="servermain:Device" and name()!="servermain:TagGroup"'>
              <xsl:apply-templates>
                <xsl:with-param name='tag-name' select='$tag-name'/>
              </xsl:apply-templates>
            </xsl:if>
          </div>
        </xsl:if>
        <!--<xsl:if test='count(.//*[text()])=0'>
          <xsl:call-template name="value-row"/>
        </xsl:if>-->
      </xsl:if>
    </xsl:if>
  </xsl:template>
  <xsl:template match="servermain:TagList">
    <xsl:param name="tag-name"/>
    <xsl:if test="./servermain:Tag">
      <div class="if-xs">
        <div class="indent">
          <xsl:apply-templates>
            <xsl:with-param name="tag-name" select="$tag-name"/>
          </xsl:apply-templates>
        </div>
      </div>
      <div class="if-not-xs">
        <div class="page-break-inside-avoid">
          <div class="title">Tags</div>
          <div class="indent">
            <div class="row header">
              <div class="col-xs-12 col-sm-4 col-md-3">
                <div class="box">
                  Name
                </div>
              </div>
              <div class="col-xs-12 col-sm-3 col-md-2">
                <div class="box">
                  Address
                </div>
              </div>
              <div class="col-xs-12 col-sm-2 col-md-1">
                <div class="box">
                  Data type
                </div>
              </div>
              <div class="col-xs-12 col-sm-1">
                <div class="box">
                  R/W
                </div>
              </div>
              <div class="col-xs if-not-sm">
                <div class="box">
                  Description
                </div>
              </div>
            </div>
          </div>
          <xsl:apply-templates>
            <xsl:with-param name="tag-name" select="$tag-name"/>
          </xsl:apply-templates>
        </div>
      </div>
    </xsl:if>      
  </xsl:template>
  <xsl:template match="servermain:Tag">
    <xsl:param name="tag-name"/>
		<xsl:variable name="name">
			<xsl:call-template name="replace">
				<xsl:with-param name="text" select="servermain:Name/text()" />
				<xsl:with-param name="replace" select="'\\'" />
				<xsl:with-param name="by" select="'.'" />
			</xsl:call-template>
		</xsl:variable>
    <div class="if-not-xs">
      
      <div class="row">
        <div class="col-xs-12 col-sm-4 col-md-3">
          <div class="box break">
            <xsl:value-of select="servermain:Name"/>
          </div>
        </div>
        <div class="col-xs-12 col-sm-3 col-md-2">
          <div class="box">
            <xsl:value-of select="servermain:Address"/>
          </div>
        </div>
        <div class="col-xs-12 col-sm-2 col-md-1">
          <div class="box">
            <xsl:value-of select="servermain:DataType"/>
          </div>
        </div>
        <div class="col-xs-12 col-sm-1">
          <div class="box">
            R
            <xsl:if test="servermain:ReadWriteAccess/text()='Read/Write'">
              /W
            </xsl:if>
          </div>
        </div>
        <div class="col-xs-12 col-sm-12 col-md">
          <div class="box">
            <xsl:value-of select="servermain:Description"/>
          </div>
        </div>
        <div class="col-xs-12 if-sm">
          <div class="box">
            <hr/>
          </div>
        </div>
      </div>
			<div class="row">
				<div class="col-xs-1"></div>
				<div class="col-xs-4">
					<div class="box" title="path to tag">
						<xsl:value-of select="concat($tag-name, '.', $name)"/>
					</div>
				</div>
				<div class="col-xs">
					<div class="box break  value-status" title ="current tag value">
						<span>
							<xsl:attribute name="class" >
								<xsl:value-of select="concat('tag-' , $tag-name, '.', $name)"/>
							</xsl:attribute>
						</span>
					</div>
				</div>
			</div>
    </div>
    <div class="if-xs">
      <div class="title">
        Tag: <xsl:value-of select="servermain:Name"/>
      </div>
      <div class="row">
        <div class="col-xs-12 header">
          <div class="box">
            Address
          </div>
        </div>
        <div class="col-xs-12 value">
          <div class="box">
            <xsl:value-of select="servermain:Address"/>
          </div>
        </div>
      </div>
      <div class="row">
        <div class="col-xs-12 header">
          <div class="box">
            Data Type
          </div>
        </div>
        <div class="col-xs-12 value">
          <div class="box">
            <xsl:value-of select="servermain:DataType"/>
          </div>
        </div>
      </div>
      <div class="row">
        <div class="col-xs-12 header">
          <div class="box">
            Read/Write
          </div>
        </div>
        <div class="col-xs-12 value">
          <div class="box">
            R
            <xsl:if test="servermain:ReadWriteAccess/text()='Read/Write'">
              /W
            </xsl:if>
          </div>
        </div>
      </div>
      <div class="row">
        <div class="col-xs-12 header">
          <div class="box">
            Description
          </div>
        </div>
				
        <div class="col-xs-12 value">
          <div class="box">
            <xsl:value-of select="servermain:Description"/>
          </div>
        </div>
				<div class="col-xs-12 header">
					<div class="box">
						Path to tag
					</div>
				</div>
				<div class="col-xs-12 value">
					<div class="box break">
							<xsl:value-of select="concat('tag-' , $tag-name, '.', $name)"/>
					</div>
				</div>
				<div class="col-xs-12 header">
					<div class="box">
						Value
					</div>
				</div>
				<div class="col-xs-12 value">
					<div class="box break  value-status">
						<span>
							<xsl:attribute name="class" >
								<xsl:value-of select="concat('tag-' , $tag-name, '.', $name)"/>
							</xsl:attribute>
						</span>
					</div>
				</div>
      </div>
    </div>
  </xsl:template>


  <xsl:template match="servermain:Channel" mode="opc">
    <xsl:apply-templates select="servermain:DeviceList/servermain:Device" mode="opc">
      <xsl:with-param name="tag-name" select="servermain:Name/text()"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="servermain:Device" mode="opc">
    <xsl:param name="tag-name"/>
    <xsl:apply-templates select="*" mode="opc">
      <xsl:with-param name="tag-name" select="concat($tag-name, '.', servermain:Name/text())"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="servermain:TagGroupList" mode="opc">
    <xsl:param name="tag-name"/>
    <xsl:apply-templates select="*" mode="opc">
      <xsl:with-param name="tag-name" select="$tag-name"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="servermain:TagList" mode="opc">
    <xsl:param name="tag-name"/>
    <xsl:apply-templates select="*" mode="opc">
      <xsl:with-param name="tag-name" select="$tag-name"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="servermain:TagGroup" mode="opc">
    <xsl:param name="tag-name"/>
    <xsl:apply-templates select="*" mode="opc">
      <xsl:with-param name="tag-name" select="concat($tag-name, '.', servermain:Name/text())"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="servermain:Tag" mode="opc">
    <xsl:param name="tag-name"/>
		<xsl:variable name="name">
			<xsl:call-template name="replace">
				<xsl:with-param name="text" select="servermain:Name/text()" />
				<xsl:with-param name="replace" select="'\'" />
				<xsl:with-param name="by" select="'\\'" />
			</xsl:call-template>
		</xsl:variable>
      &quot;<xsl:value-of select="concat($tag-name, '.', $name)"/>&quot;,
    
  </xsl:template>
	<xsl:template name="replace">
		<xsl:param name="text" />
		<xsl:param name="replace" />
    <xsl:param name="by" />
		<xsl:choose>
			<xsl:when test="contains($text, $replace)">
				<xsl:value-of select="substring-before($text,$replace)" />
				<xsl:value-of select="$by" />
				<xsl:call-template name="replace">
					<xsl:with-param name="text"
					select="substring-after($text,$replace)" />
					<xsl:with-param name="replace" select="$replace" />
					<xsl:with-param name="by" select="$by" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
  <xsl:template match="*" mode="opc"/>

  <xsl:template name="SplitCamelCase">
  <xsl:param name="text" />
  <xsl:param name="digitsMode" select="0" />
  <xsl:variable name="upper">(ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
  <xsl:variable name="digits">0123456789</xsl:variable>
 
  <xsl:if test="$text != ''">
    <xsl:variable name="letter" select="substring($text, 1, 1)" />

    <xsl:choose>
      <xsl:when test="contains($upper, $letter)">
        <xsl:text> </xsl:text>
        <xsl:value-of select="$letter" />
      </xsl:when>
      <xsl:when test="contains($digits, $letter)">
        <xsl:choose>
          <xsl:when test="$digitsMode != 1">
            <xsl:text> </xsl:text>
          </xsl:when>
        </xsl:choose>
        <xsl:value-of select="$letter" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$letter"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="SplitCamelCase">
      <xsl:with-param name="text" select="substring-after($text, $letter)" />
      <xsl:with-param name="digitsMode" select="contains($digits, $letter)" />
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template name="breakIntoWords">
  <xsl:param name="string" />
  <xsl:choose>
    <xsl:when test="string-length($string) &lt; 2">
      <xsl:value-of select="$string" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="breakIntoWordsHelper">
        <xsl:with-param name="string" select="$string" />
        <xsl:with-param name="token" select="substring($string, 1, 1)" />
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="breakIntoWordsHelper">
  <xsl:param name="string" select="''" />
  <xsl:param name="token" select="''" />
  <xsl:choose>
    <xsl:when test="string-length($string) = 0" />
    <xsl:when test="string-length($token) = 0" />
    <xsl:when test="string-length($string) = string-length($token)">
      <xsl:value-of select="$token" />
    </xsl:when>
    <xsl:when test="contains('ABCDEFGHIJKLMNOPQRSTUVWXYZ',substring($string, string-length($token) + 1, 1))">
      <xsl:value-of select="concat($token, ' ')" />
      <xsl:call-template name="breakIntoWordsHelper">
        <xsl:with-param name="string" select="substring-after($string, $token)" />
        <xsl:with-param name="token" select="substring($string, string-length($token), 1)" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="breakIntoWordsHelper">
        <xsl:with-param name="string" select="$string" />
        <xsl:with-param name="token" select="substring($string, 1, string-length($token) + 1)" />
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
</xsl:stylesheet>